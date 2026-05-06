import os

def fix_1_line(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
        lines.pop(159)
        duplicate_row = lines[158]
        lines.append(duplicate_row)
        with open(file_path, 'w') as file:
            file.writelines(lines)
        print(f"File '{file_path}' fixed with 1-line correction.")
    except Exception as e:
        print(f"Error processing '{file_path}': {e}")

def fix_2_lines(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
        lines.pop(158)
        duplicate_row = lines[157]
        lines.append(duplicate_row)
        lines.append(duplicate_row)
        with open(file_path, 'w') as file:
            file.writelines(lines)
        print(f"File '{file_path}' fixed with 2-line correction.")
    except Exception as e:
        print(f"Error processing '{file_path}': {e}")

def get_column_count(line):
    return len(line.strip().split())

def check_and_fix_file(file_path, manual_review_list):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        num_lines = len(lines)

        if num_lines == 160:
            if get_column_count(lines[159]) < get_column_count(lines[158]):
                fix_1_line(file_path)
            else:
                print(f"File '{file_path}' appears normal. No fix needed.")
        elif num_lines == 159:
            if get_column_count(lines[158]) < get_column_count(lines[157]):
                fix_2_lines(file_path)
            else:
                manual_review_list.append(file_path)
        else:
            manual_review_list.append(file_path)
    except Exception as e:
        print(f"Error reading '{file_path}': {e}")
        manual_review_list.append(file_path)

set1=[1,2,3,4,5]
set1indx=[70,91]
set2=[6,7,8,9,10]
set2indx=[430,449]
set3=[11,12,13,14,15]
set3indx=[225,245]
set4=[16,17,18,19,20]
set4indx=[135,155]
set5=[21,22,23,24,25]
set5indx=[325,347]

def main():
    celltypes = set5
    trial_indices = range(set5indx[0],set5indx[1])  # Adjust based on your actual index range
    manual_review_list = []

    base_path = "E:/lat/Pattern2uA11.35"

    for celltype in celltypes:
        for x in trial_indices:
            file_path = os.path.join(base_path, f"Vm_axon_{celltype}_{x}.dat")
            if os.path.isfile(file_path):
                check_and_fix_file(file_path, manual_review_list)
            else:
                print(f"File not found: {file_path}")

    # Save manual review list
    if manual_review_list:
        review_path = os.path.join(base_path, "manual_review.txt")
        with open(review_path, 'w') as f:
            for item in manual_review_list:
                f.write(f"{item}\n")
        print(f"\nManual review needed for {len(manual_review_list)} files. See 'manual_review.txt'.")
    else:
        print("\nAll files processed without issues.")

if __name__ == "__main__":
    main()
