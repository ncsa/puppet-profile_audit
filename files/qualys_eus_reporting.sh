if [[ $EUID -eq 0 ]]; then
	function subscription-manager {
		/root/scripts/qualys_eus_reporting.sh "$@"
	}
fi
