FROM ruby:2.4 as builder
LABEL builder="builder"

#---some useful tools for interactive usage---#
RUN apt-get update && \
  apt-get install -y --no-install-recommends curl

#---install summon and summon-conjur---#
RUN curl -sSLk https://raw.githubusercontent.com/cyberark/summon/master/install.sh \
  | env TMPDIR=$(mktemp -d) bash && \
  curl -sSLk https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh \
  | env TMPDIR=$(mktemp -d) bash
# as per https://github.com/cyberark/summon#linux
# and    https://github.com/cyberark/summon-conjur#install
ENV PATH="/usr/local/lib/summon:${PATH}"

# ============= CLOUD-API CONTAINER ============== #

FROM busybox

#---copy summon into image---#
COPY --from=builder /usr/local/lib/summon /usr/local/lib/summon
COPY --from=builder /usr/local/bin/summon /usr/local/bin/summon

WORKDIR /app

#---copy secrets.yml into image---#
COPY secrets.yml /etc/secrets.yml

# ADD . .

ENTRYPOINT ["summon", "--provider", "summon-conjur", "-f", "/etc/secrets.yml", "/bin/sh", "-c", "while true; do printenv | grep PASSWORD; sleep 5; done"]
