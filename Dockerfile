FROM oschwengers/bakta:v1.12.0

# Reference data (Bakta DB v6) is mounted by CTS at /ref_data
# After CTS unpacks the bundle, the database lives at /ref_data/db/
ENV BAKTA_DB /ref_data/db

# bakta is installed via conda at /opt/conda/bin/bakta. We need conda's bin
# directory on PATH for two reasons:
#   1. So `bakta` itself resolves at runc exec
#   2. So bakta's subprocesses (tRNAscan-SE, prodigal, aragorn, infernal,
#      hmmer, blast, etc., all also under /opt/conda/bin) resolve when
#      bakta invokes them by name
# Setting only ENTRYPOINT to /opt/conda/bin/bakta (as 0.1.1 did) fixes #1
# but not #2; bakta would then crash with "tRNAscan-SE not found".
ENV PATH="/opt/conda/bin:${PATH}"

# Overlay diamond v2.2.0 over the conda-shipped binary.
# Reason: the conda-shipped diamond (v2.1.21) intermittently hangs at the
# alignment step during bakta's pseudogene detection. Confirmed upstream as a
# diamond issue (oschwengers/bakta#424, bbuchfink/diamond#930). v2.2.0 release
# notes call out "Fixed an issue that could cause hanging instead of correct
# termination in case of an error" which matches the observed behavior.
ARG DIAMOND_VERSION=2.2.0
RUN cd /tmp \
 && wget -q https://github.com/bbuchfink/diamond/releases/download/v${DIAMOND_VERSION}/diamond-linux64.tar.gz \
 && tar xzf diamond-linux64.tar.gz \
 && install -m 0755 diamond /opt/conda/bin/diamond \
 && rm -f diamond-linux64.tar.gz diamond \
 && /opt/conda/bin/diamond version

ENTRYPOINT ["bakta"]
