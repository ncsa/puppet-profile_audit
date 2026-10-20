#!/usr/bin/python3
#
# auditd-kmod-syslog
#
# Minimal auditd parser for kernel module operations.
#
# Coalesces SYSCALL, KERN_MODULE, and PROCTITLE records belonging to
# init_module/finit_module/delete_module audit events into one syslog line.
#
# Expected audit keys:
#   kmod_load - module load events
#   kmod_unload - module unload events
#

import os
import re
import sys
import syslog

events = {}

event_re = re.compile(r'msg=audit\(([^)]+)\)')
field_re = re.compile(r'(\w+)=(?:"([^"]*)"|(\S+))')


def fields(line):
    # Drop auditd enrichment fields
    line = line.split("\x1d", 1)[0]

    return {
        m.group(1): (m.group(2) if m.group(2) is not None else m.group(3))
        for m in field_re.finditer(line)
    }


syslog.openlog("auditd-kmod", facility=syslog.LOG_LOCAL6)

for line in sys.stdin:
    eid = event_re.search(line).group(1)
    f = fields(line)
    typ = f.get("type")

    # Look for a SYSCALL record with our custom tags
    if typ == "SYSCALL":
        if f.get("key") not in ("kmod_load", "kmod_unload"):
            continue

        # Parse the auditd record and create an event entry
        events[eid] = {
            "action": "load" if f["key"] == "kmod_load" else "unload",
            "success": f.get("success"),
            "exit": f.get("exit"),
            "pid": f.get("pid"),
            "ppid": f.get("ppid"),
            "auid": f.get("auid"),
            "uid": f.get("uid"),
            "tty": f.get("tty"),
            "ses": f.get("ses"),
            "comm": f.get("comm"),
            "exe": f.get("exe")
        }

    # Get the name of the module from the accompanying KERN_MODULE record
    elif typ == "KERN_MODULE" and eid in events:
        events[eid]["module"] = f.get("name")

    # PROCTITLE should be the last record of the event
    # Decode the string for the full command line with arguments
    # Then finalize the event and push the syslog entry
    elif typ == "PROCTITLE" and eid in events:
        p = events.pop(eid)

        try:
            cmd = bytes.fromhex(f["proctitle"]).replace(b"\0", b" ").decode()
        except (ValueError, UnicodeDecodeError):
            cmd = f.get("proctitle")

        msg = (
            f'kernel_module'
            f' action={p["action"]}'
            f' module={p.get("module", "unknown")}'
            f' success={p["success"]}'
            f' exit={p["exit"]}'
            f' pid={p["pid"]}'
            f' ppid={p["ppid"]}'
            f' auid={p["auid"]}'
            f' uid={p["uid"]}'
            f' tty="{p["tty"]}"'
            f' ses="{p["ses"]}"'
            f' comm="{p["comm"]}"'
            f' exe="{p["exe"]}"'
            f' cmd="{cmd}"'
        )

        syslog.syslog(syslog.LOG_INFO, msg)
