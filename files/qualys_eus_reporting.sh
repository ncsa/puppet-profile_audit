if [[ $EUID -eq 0 ]]; then
	function subscription-manager {
		/root/qualys_eus_reporting.sh "$@"
	}
fi
