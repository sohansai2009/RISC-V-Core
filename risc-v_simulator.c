#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// --- Configuration ---
#define IMEM_SIZE 32
#define DMEM_SIZE 4096

// --- Global State ---
uint32_t R[32] = {0}; // The RISC-V Register File (R[0] is x0, R[31] is x31)
uint32_t PC = 0x10074; // Matches your _start address
uint8_t data_memory[DMEM_SIZE];
uint32_t instruction_memory[IMEM_SIZE];
int is_halted = 0;


void load_initial_regfile(const char *filename) {
    // This function initializes the global array R[32] from the file.
    FILE *file = NULL;
    char line[100];
    uint32_t value;
    // Start index at 0. We'll skip R[0] if the file doesn't explicitly contain it.
    int reg_index = 0; 
    
    // Open the file for reading
    file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: Could not open file %s. Check path/permissions.\n", filename);
        exit(1);
    }
    
    // Read the file line by line
    while (fgets(line, sizeof(line), file) != NULL) {
        // Stop if we exceed the 32 register capacity
        if (reg_index >= 32) break; 

        // Parsing the Hex Value
        if (sscanf(line, "%x", &value) == 1) {
            // R[0] must always be 0. We only load non-zero values into R[1] through R[31].
            // We assume the file starts with R[1] data on the first line.
            if (reg_index > 0) { 
                R[reg_index] = value;
            }
            reg_index++; // Move to the next register index
        }
    }
    
    fclose(file);
    // The total number of registers loaded (excluding the automatic R[0]=0)
    printf("INFO: C Register File initialized with %d entries (R[1] to R[%d]) from %s.\n", reg_index - 1, reg_index - 1, filename);
}

// --- Helper: Sign Extension ---
int32_t sign_extend_12(uint32_t instruction) {
    uint32_t imm12_field = (instruction & 0xFFF00000);
    return (int32_t)imm12_field >> 20;
}
uint32_t instr;
// --- Load Instructions (Raw Load with Debug) ---
int load_instructions(const char *hex_file_path) {
    FILE *fp;
    char line[128];
    int word_index = 0;

    fp = fopen(hex_file_path, "r");
    if (fp == NULL) { perror("Error opening .hex file"); return -1; }

    printf("--- Loading Instructions (Raw Format) ---\n");
    while (fgets(line, sizeof(line), fp) != NULL) {
        if (word_index >= IMEM_SIZE) break;

        uint32_t raw_hex;
        // Parse the hex string from the file
        if (sscanf(line, "%x", &raw_hex) == 1) {
            // DIRECT ASSIGNMENT: No swapping or conversion
            instruction_memory[word_index] = raw_hex;
            
            instr=raw_hex; //the instruction which is currently being fetched
            printf("DEBUG CHECK: Index 0 loaded: 0x%08X. Start PC is 0x%X\n", raw_hex, PC);
            // ----------------------------------------------------
            
            word_index++;
        }
    }
    
    fclose(fp);
    return word_index;
}

// --- Execute Instruction (FIXED) ---
void execute_instruction(uint32_t instruction) {
    uint32_t opcode = instruction & 0x7F;
    uint32_t rd = (instruction >> 7) & 0x1F; 
    uint32_t funct3 = (instruction >> 12) & 0x07;
    uint32_t rs1 = (instruction >> 15) & 0x1F;
    uint32_t rs2 = (instruction >> 20) & 0x1F;
    uint32_t funct7 = (instruction >> 25) & 0x7F;

    if (rd == 0) rd = 0; // Target x0 is always ignored

    // --- TERMINATION (ECALL) ---
    if (instruction == 0x00000073) {
        printf(">>> ECALL DETECTED at PC 0x%X <<<\n", PC);
        is_halted = 1;
        return;
    }

    // --- R-TYPE (ADD, SUB, etc.) Opcode 0x33 ---
    if (opcode == 0x33) { 
        if (funct3 == 0x0) {
            if (funct7 == 0x00) { // ADD
                R[rd] = R[rs1] + R[rs2];
                printf("Executed: ADD x%d, x%d, x%d\n", rd, rs1, rs2);
            }
            else if (funct7 == 0x20) { // SUB
                R[rd] = R[rs1] - R[rs2];
                printf("Executed: SUB x%d, x%d, x%d\n", rd, rs1, rs2);
            }
        }
    }
    // --- I-TYPE ARITHMETIC (ADDI) Opcode 0x13 ---
    else if (opcode == 0x13) { 
        int32_t imm = sign_extend_12(instruction);
        if (funct3 == 0x0) { // ADDI
            R[rd] = (int32_t)R[rs1] + imm;
            printf("Executed: ADDI x%d, x%d, %d\n", rd, rs1, imm);
        }
        else {
            printf("ERROR: Unknown Funct3 %d for Opcode 0x13 at PC 0x%X\n", funct3, PC);
        }
    }
    // --- LOAD (LW) Opcode 0x03 ---
    else if (opcode == 0x03) { 
        int32_t imm = sign_extend_12(instruction);
        uint32_t addr = R[rs1] + imm;
        if (funct3 == 0x2) { // LW
            if (addr < DMEM_SIZE - 3) {
                R[rd] = data_memory[addr] | (data_memory[addr+1] << 8) |
                        (data_memory[addr+2] << 16) | (data_memory[addr+3] << 24);
                printf("Executed: LW x%d, %d(x%d) -> 0x%X\n", rd, imm, rs1, R[rd]);
            } else {
                 printf("ERROR: Load Access Fault at 0x%X\n", addr);
            }
        }
    }
    // --- STORE (SW) Opcode 0x23 ---
    else if (opcode == 0x23) { 
        uint32_t imm_low = (instruction >> 7) & 0x1F;
        uint32_t imm_high = (instruction >> 25) & 0x7F;
        int32_t imm_val = (int32_t)(imm_high << 5) | imm_low;
        if (imm_high & 0x40) imm_val |= 0xFFFFF800; // Sign extend bit 11

        uint32_t addr = R[rs1] + imm_val;
        uint32_t data = R[rs2];
        
        if (funct3 == 0x2) { // SW
            if (addr < DMEM_SIZE - 3) {
                data_memory[addr] = data & 0xFF;
                data_memory[addr+1] = (data >> 8) & 0xFF;
                data_memory[addr+2] = (data >> 16) & 0xFF;
                data_memory[addr+3] = (data >> 24) & 0xFF;
                printf("Executed: SW x%d, %d(x%d) -> [0x%X] = 0x%X\n", rs2, imm_val, rs1, addr, data);
            } else {
                 printf("ERROR: Store Access Fault at 0x%X\n", addr);
            }
        }
    }
    // --- U-TYPE (LUI) Opcode 0x37 ---
    else if (opcode == 0x37) { 
        R[rd] = instruction & 0xFFFFF000;
        printf("Executed: LUI x%d, 0x%X\n", rd, R[rd]);
    }
    // --- CATCH ALL UNKNOWN ---
    else {
        printf("CRITICAL ERROR: Unimplemented Opcode 0x%02X at PC 0x%X (Instr: 0x%08X)\n", opcode, PC, instruction);
    }

    R[0] = 0; // Enforcement
}

// --- Main ---
void dump_golden_state() {
    FILE *f = fopen("golden_registers.txt", "w");
    if (f) {
        for (int i = 0; i < 32; i++) fprintf(f, "x%02d: %08X\n", i, R[i]);
        fclose(f);
        printf("\nGolden data generated: golden_registers.txt\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) { 
        printf("Usage: %s <hex_file>\n", argv[0]); 
        printf("Example: ./golden_sim instr_mem.hex\n"); // Added example
        return 1; 
    }
    
    // 1. Initialize Register File from file BEFORE execution
    load_initial_regfile("reg_file.txt"); 

    // 2. Load instructions from command line argument
    int loaded = load_instructions(argv[1]);
    printf("Successfully loaded %d instructions.\n", loaded);

    printf("\n--- Starting Sequential Execution (Golden Run) ---\n");
    
    int cycles = 0;
    while (!is_halted && cycles < 100) {
        int idx = (PC - 0x10074) / 4; 
        
        if (idx >= loaded || idx < 0) {
            printf("PC out of bounds (0x%X). Halting.\n", PC);
            break;
        }
        
        uint32_t instr = instruction_memory[idx];
        printf("[Cycle %d] PC: 0x%X | Instr: 0x%08X | Opcode: 0x%02X\n", 
               cycles, PC, instr, instr & 0x7F);
        
        execute_instruction(instr);
        
        // Simple PC increment
        PC += 4;
        cycles++;
    }
    
    // 3. Dump final state for comparison
    dump_golden_state();
    return 0;
}
