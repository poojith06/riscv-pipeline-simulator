import os
import subprocess
import shutil
import glob
import csv
import re
import zipfile
import sys

# Base directory: where this script lives
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Paths relative to base
ROOT_DIR = os.path.join(BASE_DIR, "root")
CODES_DIR = os.path.join(BASE_DIR, "testcases", "Pipelined", "Codes")
GOLDEN_DIR = os.path.join(BASE_DIR, "testcases", "Pipelined", "Outputs")
ENCODER = os.path.join(BASE_DIR, "riscv_instruction_encoder.py")
CSV_FILE = os.path.join(BASE_DIR, "results.csv")
ERROR_FILE = os.path.join(BASE_DIR, "error.txt")

# Testbench candidates (case-insensitive match)
TESTBENCH_NAMES = ["pipelined_processor_tb.v", "pipelined_tb.v", "processor_tb.v", "pipe_tb.v", "pipetb.v", "pipelinedtb.v"]

# Marks: Tests 00-24: 1 marks each, Test 25: 3 marks, Tests 26-39: 1 marks each, Tests 40-45: 3 marks each, Test 46: 1 marks
# Total = 25*1 + 1*3 + 14*1 + 6*3 + 1*1 = 61 marks
MARKS = {}
for i in range(25):
    MARKS[i] = 1
MARKS[25] = 3
for i in range(26, 40):
    MARKS[i] = 1
for i in range(40, 46):
    MARKS[i] = 3
MARKS[46] = 1

def find_team_info(folder):
    """Find team_info.txt with typo resilience."""
    for f in os.listdir(folder):
        if not os.path.isfile(os.path.join(folder, f)):
            continue
        name_lower = f.lower()
        if not name_lower.endswith('.txt'):
            continue
        normalized = name_lower.replace('_', '').replace('-', '').replace(' ', '')
        if 'teaminfo' in normalized:
            return os.path.join(folder, f)
    return None


def extract_roll_numbers(filepath):
    """Extract roll numbers: 10-digit numbers starting with 202."""
    with open(filepath, 'r', errors='ignore') as f:
        content = f.read()
    return re.findall(r'202\d{7}', content)


def find_testbench(folder):
    """Find testbench file from candidates (case-insensitive)."""
    files = os.listdir(folder)
    for tb_name in TESTBENCH_NAMES:
        for f in files:
            if f.lower() == tb_name.lower():
                return f
    return None


def find_verilog_folder(base_path):
    """Find the folder containing Verilog files, preferring one with 'pipe' in the name."""
    candidates = []
    for root, dirs, files in os.walk(base_path):
        dirs[:] = [d for d in sorted(dirs) if not d.startswith('__') and not d.startswith('.')]
        if any(f.endswith('.v') for f in files):
            candidates.append(root)
            
    if not candidates:
        return None
        
    # Prefer candidates that have 'pipe' in the folder name
    for c in candidates:
        if 'pipe' in os.path.basename(c).lower():
            return c
            
    return candidates[0]


def compare_register_files(output_file, golden_file):
    """Compare first 32 lines case-insensitively, ignoring line 28 (0-indexed)."""
    try:
        with open(output_file, 'r') as f:
            out_lines = [line.strip().lower() for line in f.readlines()[:32]]
        with open(golden_file, 'r') as f:
            gold_lines = [line.strip().lower() for line in f.readlines()[:32]]
            
        if len(out_lines) < 32 or len(gold_lines) < 32:
            return False        
        
        return out_lines == gold_lines
    except Exception:
        return False


def main():
    testcases = sorted(glob.glob(os.path.join(CODES_DIR, "*.s")))
    if not testcases:
        print("No testcase files found in", CODES_DIR)
        sys.exit(1)

    print(f"Found {len(testcases)} testcases")

    error_f = open(ERROR_FILE, 'w')

    # Discover all submissions, deduplicate by team number
    teams = {}  # team_no -> (folder_path, zip_path)

    for folder_name in sorted(os.listdir(ROOT_DIR)):
        folder_path = os.path.join(ROOT_DIR, folder_name)
        if not os.path.isdir(folder_path):
            continue

        zips = [f for f in os.listdir(folder_path) if f.lower().endswith('.zip')]
        if not zips:
            error_f.write(f"No zip file found in {folder_name}\n")
            continue

        zip_file = zips[0]
        match = re.search(r'[Tt]eam[_\s-]?(\d+)', zip_file)
        if not match:
            error_f.write(f"Cannot extract team number from '{zip_file}' in {folder_name}\n")
            continue

        team_no = match.group(1).zfill(2)
        if team_no not in teams:
            teams[team_no] = (folder_path, os.path.join(folder_path, zip_file))

    print(f"Found {len(teams)} unique teams\n")

    # Initialize CSV file with headers
    with open(CSV_FILE, 'w', newline='') as f:
        writer = csv.writer(f)
        header = ['Team No', 'Roll No'] + [f'Test_{i:02d}' for i in range(47)] + ['Total']
        writer.writerow(header)

    # Process each team
    results = {}  # team_no -> {'roll_numbers': [...], 'marks': [...]}

    for team_no in sorted(teams.keys()):
        folder_path, zip_path = teams[team_no]
        print(f"{'='*60}")
        print(f"Team {team_no} — {os.path.basename(folder_path)}")
        print(f"{'='*60}")

        # Extract zip
        try:
            with zipfile.ZipFile(zip_path, 'r') as z:
                z.extractall(folder_path)
            print(f"  Extracted {os.path.basename(zip_path)}")
        except Exception as e:
            msg = f"Team {team_no}: Zip extraction failed — {e}"
            error_f.write(msg + "\n")
            print(f"  {msg}")
            results[team_no] = {'roll_numbers': [], 'marks': [0] * 21}
            continue

        # Find the folder with Verilog files
        inner = find_verilog_folder(folder_path)
        if not inner:
            msg = f"Team {team_no}: No Verilog files found after extraction"
            error_f.write(msg + "\n")
            print(f"  {msg}")
            results[team_no] = {'roll_numbers': [], 'marks': [0] * 21}
            continue
        print(f"  Working dir: .../{os.path.basename(inner)}")

        # Find team info and extract roll numbers
        info_file = find_team_info(inner)
        roll_numbers = []
        if info_file:
            roll_numbers = extract_roll_numbers(info_file)
            print(f"  Roll numbers: {roll_numbers}")
            if len(roll_numbers) < 3:
                error_f.write(f"Team {team_no}: Found only {len(roll_numbers)} roll numbers in {os.path.basename(info_file)}\n")
        else:
            error_f.write(f"Team {team_no}: team_info.txt not found\n")
            print(f"  WARNING: team_info.txt not found")

        # Find testbench
        tb_file = find_testbench(inner)
        if not tb_file:
            msg = f"Team {team_no}: No testbench found (looked for {TESTBENCH_NAMES})"
            error_f.write(msg + "\n")
            print(f"  {msg}")
            results[team_no] = {'roll_numbers': roll_numbers, 'marks': [0] * 21}
            continue
        print(f"  Testbench: {tb_file}")

        # Compile testbench once per team
        compile_result = subprocess.run(
            ["iverilog", "-o", "a.out", tb_file],
            cwd=inner,
            capture_output=True, text=True
        )
        if compile_result.returncode != 0:
            msg = f"Team {team_no}: Compilation failed"
            error_f.write(msg + " — " + compile_result.stderr[:500].replace('\n', ' ') + "\n")
            print(f"  COMPILATION FAILED")
            results[team_no] = {'roll_numbers': roll_numbers, 'marks': [0] * 21}
            continue
        print(f"  Compiled successfully")

        # Create Outputs folder for this submission
        outputs_dir = os.path.join(inner, "Outputs")
        os.makedirs(outputs_dir, exist_ok=True)

        marks = []
        instructions_file = os.path.join(inner, "instructions.txt")
        register_file = os.path.join(inner, "register_file.txt")

        for tc_path in testcases:
            tc_name = os.path.basename(tc_path)
            prefix = tc_name[:2]
            tc_idx = int(prefix)

            # Remove stale register_file.txt before simulation
            if os.path.exists(register_file):
                os.remove(register_file)

            # Encode assembly -> machine code
            encode_result = subprocess.run(
                [sys.executable, ENCODER, tc_path, "-e", instructions_file],
                cwd=BASE_DIR,
                capture_output=True, text=True
            )
            if encode_result.returncode != 0:
                error_f.write(f"Team {team_no}, Test {prefix}: Encoding failed — {encode_result.stderr[:200]}\n")
                marks.append(0)
                continue

            # Run simulation with timeout
            try:
                sim_result = subprocess.run(
                    ["vvp", "a.out"],
                    cwd=inner,
                    capture_output=True, text=True,
                    timeout=30
                )
            except subprocess.TimeoutExpired:
                error_f.write(f"Team {team_no}, Test {prefix}: Simulation timed out (30s)\n")
                marks.append(0)
                continue

            # Copy output to team's Outputs folder
            output_file = os.path.join(outputs_dir, f"{prefix}_register_file.txt")
            if os.path.exists(register_file):
                shutil.copy2(register_file, output_file)
            else:
                error_f.write(f"Team {team_no}, Test {prefix}: register_file.txt not produced\n")
                marks.append(0)
                continue

            # Compare with golden output
            golden_file = os.path.join(GOLDEN_DIR, f"{prefix}_register_file.txt")
            if os.path.exists(golden_file) and compare_register_files(output_file, golden_file):
                marks.append(MARKS[tc_idx])
                print(f"  Test {prefix}: PASS (+{MARKS[tc_idx]})")
            else:
                marks.append(0)
                print(f"  Test {prefix}: FAIL")

        results[team_no] = {'roll_numbers': roll_numbers, 'marks': marks}
        total = sum(marks)
        print(f"  TOTAL: {total}/61\n")

        # Append team's result to CSV immediately
        with open(CSV_FILE, 'a', newline='') as f:
            writer = csv.writer(f)
            m = marks if len(marks) == 47 else marks + [0] * (47 - len(marks))
            total_m = sum(m)
            if not roll_numbers:
                writer.writerow([team_no, ''] + m + [total_m])
            else:
                for roll in roll_numbers:
                    writer.writerow([team_no, roll] + m + [total_m])

    error_f.close()

    print(f"\n{'='*60}")
    print(f"Results written to {CSV_FILE}")
    print(f"Errors logged to {ERROR_FILE}")
    print(f"{'='*60}")

    # remove hex_instructions.txt file in this directory if it exists
    hex_file = os.path.join(BASE_DIR, "hex_instructions.s")
    if os.path.exists(hex_file):
        os.remove(hex_file)

if __name__ == "__main__":
    main()
