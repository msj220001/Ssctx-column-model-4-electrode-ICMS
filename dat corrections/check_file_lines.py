import glob

for file in glob.glob("Vm_axon_6_44*.dat"):
    print(f"File: {file}")
    with open(file, 'r') as f:
        ncols = [len(line.strip().split()) for line in f]
    counts = {}
    for n in ncols:
        counts[n] = counts.get(n, 0) + 1
    for col_count, freq in sorted(counts.items()):
        print(f"{freq} {col_count}")