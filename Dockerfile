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
# but not #2 — bakta would then crash with "tRNAscan-SE not found".
ENV PATH="/opt/conda/bin:${PATH}"

ENTRYPOINT ["bakta"]
