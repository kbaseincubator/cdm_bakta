# cdm_bakta

CTS (CDM Task Service) job wrapper for [Bakta](https://github.com/oschwengers/bakta), a rapid and standardized bacterial genome annotation tool.

## Container

Wraps the official [`oschwengers/bakta`](https://hub.docker.com/r/oschwengers/bakta) image (v1.12.0).

Published to `ghcr.io/kbaseincubator/cdm_bakta`.

**Entrypoint:** `bakta` (no subcommand). Append Bakta flags as arguments.

**Reference data:** Required. CTS mounts the Bakta DB v6 at `/ref_data/db/`. The image sets `BAKTA_DB=/ref_data/db`, so callers do not need to pass `--db`.

We use the **full DB** (~32GB compressed, ~84GB unpacked) for maximum annotation specificity (UniRef100 + UniRef90 + UniRef50). Light DB is available but not used in this deployment.

## Usage via CTS

See `demo.ipynb` in this repo for an end-to-end run.

### Example

```python
job = tscli.submit_job(
    "ghcr.io/kbaseincubator/cdm_bakta:0.1.3@sha256:ab3d636d9381fdd57a8b21e3a2403663987f57f123027fa7a773474e66d9a827",
    input_files,                         # nucleotide FASTA (genome assemblies), one per container
    "cts/io/<your_username>/output/bakta/run1",
    cluster="kbase",
    declobber=True,
    output_mount_point="/out",
    args=[
        "--output", "/out",
        "--threads", "4",                # match cpus
        "--keep-contig-headers",
        "--skip-plot",                   # optional: skip the circular PNG/SVG plots
        "--force",                       # required: CTS pre-creates /out and bakta refuses to write into it otherwise
        tscli.insert_files(),
    ],
    num_containers=len(input_files),     # bakta annotates one genome per invocation
    cpus=4,
    memory="32GB",
    runtime="PT4H",
)
```

**Genetic code.** Bakta defaults to translation table 11. Organisms that use code 4 (UGA = Trp: *Mycoplasma*, *Spiroplasma*, and several insect endosymbionts) need `--translation-table 4`, otherwise genes are broken at internal UGA codons. Submit such genomes as a separate job.

## Output

Per input genome `<prefix>`:
- `<prefix>.tsv`: the annotation table (Sequence Id, Type, Start, Stop, Strand, Locus Tag, Gene, Product, DbXrefs). When parsing, select this file exactly: `<prefix>.inference.tsv` and `<prefix>.hypotheticals.tsv` also end in `.tsv` but have different columns.
- `<prefix>.gff3`, `.gbff`, `.embl`: standardized sequence formats
- `<prefix>.faa`, `.ffn`, `.fna`: protein and nucleotide FASTA (the `.faa` includes pseudogene CDS)
- `<prefix>.json`: full internal annotation data
- `<prefix>.txt`: summary report (its `CDSs:` count should equal the number of CDS rows in `<prefix>.tsv`)
- `<prefix>.png`, `.svg`: circular genome plots (not written with `--skip-plot`)

There is no lakehouse importer for bakta yet. The outputs report the DB as "v6.0, full"; they do not identify the AMR-updated bundle, so record the refdata ID (`30f8ba11-a456-408c-a9f9-7d232ba3ed8e`) for provenance.
