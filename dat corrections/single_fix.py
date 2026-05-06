import os

def fix_dat_file(file_path):
        try:
                with open(file_path, 'r') as file:
                        lines = file.readlines()
                lines.pop(159)
                duplicate_row = lines[158]
                lines.append(duplicate_row)
                with open(file_path, 'w') as file:
                        file.writelines(lines)
                print(f"File '{file_path}' has been fixed.")
        except Exception as e:
                print(f"An error occured while processing '{file_path}': {e}")
num_file=18
path=f"E:/lat/Pattern1uA15.40/Vm_axon_{num_file}"+"_132.dat"
fix_dat_file(path)

