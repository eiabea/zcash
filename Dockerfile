FROM debian:stretch

ENV ZCASH_CONF /home/zcash/.zcash/zcash.conf
ENV ZCASH_DATA /home/zcash/.zcash
ENV ZCASH_VERSION 2.0.0

RUN set -e && \
  # Installing required debian packages
  apt-get update -q && \
  apt-get install --no-install-recommends -q -y apt-transport-https ca-certificates wget gnupg dirmngr gosu && \
	gosu nobody true && \
  # Installing zcash
  wget -qO - https://apt.z.cash/zcash.asc | apt-key add - && \
  echo "deb [arch=amd64] https://apt.z.cash/ jessie main" | tee /etc/apt/sources.list.d/zcash.list && \
  apt-get update -q && \
  apt-get install zcash=$ZCASH_VERSION -q -y && \
  zcash-fetch-params && \
  groupadd -r zcash && \
  useradd -r -m -g  zcash zcash && \
  mv /root/.zcash-params /home/zcash/ && \
  mkdir -p /home/zcash/.zcash/ && \
  chown -R zcash:zcash /home/zcash && \
  # Cleanup
  apt-get purge -q -y apt-transport-https ca-certificates wget gnupg dirmngr && \
  apt-get clean -q -y && \
  apt-get autoclean -q -y && \
  apt-get autoremove -q -y && \
  rm -rf "/var/lib/apt/lists/*" "/var/lib/apt/lists/partial/*" "/tmp/*" "/var/tmp/*"

VOLUME /home/zcash/.zcash

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8232 8233 18232 18233

CMD [ "zcashd" ]
