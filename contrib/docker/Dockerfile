FROM debian

RUN groupadd -r p2pool && useradd -r -m -g p2pool p2pool

# grab the latest 611 source code from git, compile, install and clean up
RUN set -ex \
	&& apt-get update \

	# install dependencies
	&& apt-get install -y --no-install-recommends ca-certificates wget git \
		python-zope.interface python-twisted python-twisted-web gpg dirmngr gpg-agent \

	# grab gosu for easy step-down from root
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& wget -qO /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.12/gosu-$(dpkg --print-architecture)" \
	&& wget -qO /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.12/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \

	# install p2pool
	&& cd /home/p2pool \
	&& git clone --recursive https://github.com/fflo/sixeleven-p2pool.git p2pool \
	&& chown p2pool:p2pool -R /home/p2pool/p2pool \
	&& chmod +x /home/p2pool/p2pool/run_p2pool.py \

	# cleanup
	&& apt-get -y purge git \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV P2POOL_DATA /p2pool
RUN mkdir $P2POOL_DATA \
	&& chown p2pool:p2pool $P2POOL_DATA \
	&& ln -s $P2POOL_DATA /home/p2pool/p2pool/data
VOLUME ["/p2pool"]

COPY contrib/docker/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9332 9332
CMD ["python"]
