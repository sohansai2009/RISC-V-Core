import sys
import re

def parse_reg_file(filename):
    """
    Parses a register dump file. 
    Supports two formats:
    1. "x0: 00000000" or "x00: 00000000"
    2. "Reg number :0, data:00000000"
    
    Returns: A dictionary {reg_index (int): value (int)}
    """
    regs = {}
    
    # Regex for Format 1: "x00: 1234ABCD"
    regex_fmt1 = re.compile(r"x(\d+)\s*:\s*([0-9a-fA-F]+)")
    
    # Regex for Format 2: "Reg number :0, data:00000000"
    # Handles variable spacing around colons/commas
    regex_fmt2 = re.compile(r"Reg number\s*:\s*(\d+).*data\s*:\s*([0-9a-fA-F]+)", re.IGNORECASE)

    try:
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                match1 = regex_fmt1.search(line)
                match2 = regex_fmt2.search(line)
                
                idx = -1
                val_str = ""

                if match1:
                    idx = int(match1.group(1))
                    val_str = match1.group(2)
                elif match2:
                    idx = int(match2.group(1))
                    val_str = match2.group(2)
                
                if idx != -1:
                    # Parse hex string to integer
                    regs[idx] = int(val_str, 16)

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)

    return regs

def compare_results(file1, file2):
    print(f"--- Comparing {file1} vs {file2} ---")
    
    regs1 = parse_reg_file(file1)
    regs2 = parse_reg_file(file2)

    if not regs1:
        print(f"Warning: No registers found in {file1}")
    if not regs2:
        print(f"Warning: No registers found in {file2}")

    mismatches = 0
    
    # Compare registers x0 to x31
    print(f"{'Reg':<5} | {'Simulated Value(C) of Reg':<10} | {'RTL Output Reg Value':<10} | {'Status'}")
    print("-" * 45)

    for i in range(32):
        val1 = regs1.get(i, 0) # Default to 0 if missing
        val2 = regs2.get(i, 0)
        
        status = "MATCH"
        if val1 != val2:
            status = "FAIL  <--"
            mismatches += 1
        
        # Print x0-x31, values in Hex
        print(f"x{i:<2}   | {val1:08x}   | {val2:08x}   | {status}")

    print("-" * 45)
    if mismatches == 0:
        print("SUCCESS: All registers match!")
    else:
        print(f"FAILURE: {mismatches} mismatch(es) found.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python compare_regs.py <golden_file.txt> <dut_file.txt>")
    else:
        compare_results(sys.argv[1], sys.argv[2])
