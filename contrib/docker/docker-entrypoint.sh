#!/bin/bash
set -e

if [ "$1" = 'python' ]; then
	mkdir -p "$P2POOL_DATA"

	PROG=/home/p2pool/p2pool/run_p2pool.py
	ARGS="--logfile ${LOGFILE:-/dev/null} --give-author ${FEE_AUTHOR:-0} --fee ${FEE_POOL:-0} --max-conns ${MAX_CONNS:-33} --numaddresses ${NUMADDRESSES:-11} ${OPTS:-} --bitcoind-address ${BITCOIND_ADDRESS:-172.17.0.1} --bitcoind-rpc-port ${BITCOIND_RPC_PORT:-8332} --bitcoind-p2p-port ${BITCOIND_P2P_PORT:-8333} ${BITCOIN_RPC_USER:-bitcoinrpc} ${BITCOIN_RPC_PASS:-g1v3m3s0m3p4ss}"

	if [ ! -s "$P2POOL_DATA/config.json" ]; then
		cat <<-EOF > "$P2POOL_DATA/config.json"
		var config = {
		  // specify your personal payment addresses
		  myself : [
		    "${MYNODE_PAYOUT:-1LTG8NVtswLcd2sEjE6ZdAag9WcEES1E4k}"
		  ],
		
		  // specify a name for this node
		  node_name : "${MYNODE_NAME:-example-p2pool.611.to}:9332",

		  // data reload interval in seconds
		  reload_interval : 90,
		
		  // chart reload interval in seconds
		  reload_chart_interval : 600,
		
		  // allow conversion of bitcoin amounts into USD
		  convert_bitcoin_to_usd: false,
		
		  // misc UI options
		  show_github_ribbon: false,
		  enable_audio: true,
		
		  // custom HTML to load
		  header_url : "header.html",
		  footer_url : "footer.html",
		  ad_url :     "${MYNODE_ADURL:-}",
		
		  // address for donations
		  donation_address : "${MYNODE_PAYOUT:-1LTG8NVtswLcd2sEjE6ZdAag9WcEES1E4k}"
		}
		EOF
	fi

	if [ ! -s "/home/p2pool/p2pool/web-static/js/config.json" ]; then
		ln -s "$P2POOL_DATA/config.json" /home/p2pool/p2pool/web-static/js/
	fi

	# workaround to get P2Pool working with a pruned bitcoin blockchain
	if [ -s "/home/p2pool/p2pool/p2pool/bitcoin/networks/bitcoin.py" ]; then
		sed -i.bak '/helper.check_genesis_block/d' /home/p2pool/p2pool/p2pool/bitcoin/networks/bitcoin.py
	fi

	chown -R p2pool "$P2POOL_DATA"
	echo exec gosu p2pool "$@" "$PROG" "$ARGS"
	exec gosu p2pool "$@" $PROG $ARGS
fi

exec "$@"
