# cdm_bakta

CTS (CDM Task Service) job wrapper for [Bakta](https://github.com/oschwengers/bakta), a rapid and standardized bacterial genome annotation tool.

## Container

Wraps the official [`oschwengers/bakta`](https://hub.docker.com/r/oschwengers/bakta) image (v1.12.0).

Published to `ghcr.io/kbaseincubator/cdm_bakta`.

**Entrypoint:** `bakta` (no subcommand). Append Bakta flags as arguments.

**Reference data:** Required. CTS mounts the Bakta DB v6 at `/ref_data/db/`. The container reads it via `BAKTA_DB=/ref_data/db` env var, but you should still pass `--db /ref_data/db` explicitly in your job args for clarity.

We use the **full DB** (~32GB compressed, ~84GB unpacked) for maximum annotation specificity (UniRef100 + UniRef90 + UniRef50). Light DB is available but not used in this deployment.

## Usage via CTS

See the demo notebook at `global_share/jplfaria/bakta_demo.ipynb` on hub.berdl.kbase.us.

### Example

```python
job = tscli.submit_job(
    "ghcr.io/kbaseincubator/cdm_bakta:0.1.0@sha256:<digest>",
    input_files,                         # nucleotide FASTA (genome assemblies)
    "cts/io/jplfaria/output/bakta/test/v1",
    cluster="kbase",
    declobber=True,
    output_mount_point="/out",
    args=[
        "--db", "/ref_data/db",
        "--output", "/out",
        "--threads", "8",
        "--keep-contig-headers",
        tscli.insert_files(),
    ],
    num_containers=4,
    cpus=8,
    memory="32GB",
    runtime="PT4H"
)
```

## Output

Bakta produces ~10 files per input genome:
- `<prefix>.tsv` — annotation table (Sequence Id, Type, Start, Stop, Strand, Locus Tag, Gene, Product, DbXrefs). **Imported to Delta Lake.**
- `<prefix>.gff3`, `.gbff`, `.embl` — standardized sequence formats
- `<prefix>.faa`, `.ffn`, `.fna` — protein and nucleotide FASTA
- `<prefix>.json` — full internal annotation data
- `<prefix>.txt` — summary report
- `<prefix>.png`, `.svg` — circular genome plots
