import random

NUM_INSTR = 1020   # total instructions to generate

# ------------------- ENCODERS -------------------

def encode_r(funct7, rs2, rs1, funct3, rd, opcode):
    return ((funct7 & 0x7F) << 25) | \
           ((rs2   & 0x1F) << 20) | \
           ((rs1   & 0x1F) << 15) | \
           ((funct3 & 0x7) << 12) | \
           ((rd    & 0x1F) << 7)  | \
           (opcode & 0x7F)

def encode_i(imm, rs1, funct3, rd, opcode):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def encode_i_shift(shamt, rs1, funct3, funct7, rd, opcode):
    imm = ((funct7 & 0x7F) << 5) | (shamt & 0x1F)
    return encode_i(imm, rs1, funct3, rd, opcode)

def encode_s(imm, rs2, rs1, funct3, opcode):
    imm &= 0xFFF
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0  = imm & 0x1F
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
           (funct3 << 12) | (imm_4_0 << 7) | opcode

def encode_b(imm, rs2, rs1, funct3, opcode):
    imm &= 0x1FFF
    bit12   = (imm >> 12) & 0x1
    bit10_5 = (imm >> 5)  & 0x3F
    bit4_1  = (imm >> 1)  & 0xF
    bit11   = (imm >> 11) & 0x1
    return (bit12 << 31) | (bit10_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
           (funct3 << 12) | (bit4_1 << 8) | (bit11 << 7) | opcode

def encode_u(imm, rd, opcode):
    return (imm & 0xFFFFF000) | (rd << 7) | opcode

def encode_j(imm, rd, opcode):
    imm &= 0x1FFFFF
    bit20    = (imm >> 20) & 0x1
    bit10_1  = (imm >> 1)  & 0x3FF
    bit11    = (imm >> 11) & 0x1
    bit19_12 = (imm >> 12) & 0xFF
    return (bit20 << 31) | (bit10_1 << 21) | (bit11 << 20) | \
           (bit19_12 << 12) | (rd << 7) | opcode

# ------------------- RANDOM HELPERS -------------------

def rand_reg():
    return random.randint(0, 31)

def rand_imm_signed(bits):
    min_val = -(1 << (bits - 1))
    max_val =  (1 << (bits - 1)) - 1
    return random.randint(min_val, max_val)

def rand_imm_aligned(bits, align):
    val = rand_imm_signed(bits)
    return (val // align) * align

# ------------------- GENERATORS -------------------

R_INSTRS = ["add","sub","sll","slt","sltu","xor","srl","sra","or","and"]
I_ALU    = ["addi","slti","sltiu","xori","ori","andi","slli","srli","srai"]
I_LOAD   = ["lb","lh","lw","lbu","lhu"]
S_STORE  = ["sb","sh","sw"]
B_BRANCH = ["beq","bne","blt","bge","bltu","bgeu"]
U_TYPE   = ["lui","auipc"]
J_TYPE   = ["jal","jalr"]

ALL_GROUPS = ["R", "I_ALU", "I_LOAD", "S", "B", "U", "J"]

def gen_r(name):
    opcode = 0x33
    rd, rs1, rs2 = rand_reg(), rand_reg(), rand_reg()
    table = {
        "add":  (0x00, 0b000),
        "sub":  (0x20, 0b000),
        "sll":  (0x00, 0b001),
        "slt":  (0x00, 0b010),
        "sltu": (0x00, 0b011),
        "xor":  (0x00, 0b100),
        "srl":  (0x00, 0b101),
        "sra":  (0x20, 0b101),
        "or":   (0x00, 0b110),
        "and":  (0x00, 0b111),
    }
    funct7, funct3 = table[name]
    return encode_r(funct7, rs2, rs1, funct3, rd, opcode)

def gen_i_alu(name):
    opcode = 0x13
    rd, rs1 = rand_reg(), rand_reg()

    if name == "slli":
        sh = random.randint(0, 31)
        return encode_i_shift(sh, rs1, 0b001, 0x00, rd, opcode)
    if name == "srli":
        sh = random.randint(0, 31)
        return encode_i_shift(sh, rs1, 0b101, 0x00, rd, opcode)
    if name == "srai":
        sh = random.randint(0, 31)
        return encode_i_shift(sh, rs1, 0b101, 0x20, rd, opcode)

    imm = rand_imm_signed(12)
    funct3_map = {
        "addi": 0b000,
        "slti": 0b010,
        "sltiu":0b011,
        "xori": 0b100,
        "ori":  0b110,
        "andi": 0b111,
    }
    return encode_i(imm, rs1, funct3_map[name], rd, opcode)

def gen_i_load(name):
    opcode = 0x03
    rd, rs1 = rand_reg(), rand_reg()
    imm = rand_imm_signed(12)
    f3 = {"lb":0,"lh":1,"lw":2,"lbu":4,"lhu":5}[name]
    return encode_i(imm, rs1, f3, rd, opcode)

def gen_s(name):
    opcode = 0x23
    rs1, rs2 = rand_reg(), rand_reg()
    imm = rand_imm_signed(12)
    f3 = {"sb":0,"sh":1,"sw":2}[name]
    return encode_s(imm, rs2, rs1, f3, opcode)

def gen_b(name):
    opcode = 0x63
    rs1, rs2 = rand_reg(), rand_reg()
    imm = rand_imm_aligned(13, 2)
    f3 = {"beq":0,"bne":1,"blt":4,"bge":5,"bltu":6,"bgeu":7}[name]
    return encode_b(imm, rs2, rs1, f3, opcode)

def gen_u(name):
    rd = rand_reg()
    imm = random.randint(0, (1 << 20) - 1) << 12
    opcode = 0x37 if name == "lui" else 0x17
    return encode_u(imm, rd, opcode)

def gen_j(name):
    if name == "jal":
        rd = rand_reg()
        imm = rand_imm_aligned(21, 2)
        return encode_j(imm, rd, 0x6F)
    else:
        rd, rs1 = rand_reg(), rand_reg()
        imm = rand_imm_signed(12)
        return encode_i(imm, rs1, 0b000, rd, 0x67)

def gen_random():
    g = random.choice(ALL_GROUPS)
    if g == "R":      return gen_r(random.choice(R_INSTRS))
    if g == "I_ALU":  return gen_i_alu(random.choice(I_ALU))
    if g == "I_LOAD": return gen_i_load(random.choice(I_LOAD))
    if g == "S":      return gen_s(random.choice(S_STORE))
    if g == "B":      return gen_b(random.choice(B_BRANCH))
    if g == "U":      return gen_u(random.choice(U_TYPE))
    if g == "J":      return gen_j(random.choice(J_TYPE))

# ------------------- WRITE TO .hex -------------------

with open("instructions.hex", "w") as f:
    group = []

    for _ in range(NUM_INSTR):
        inst = gen_random()
        group.append(f"{inst:08X}")

        if len(group) == 4:
            f.write("".join(group) + "\n")
            group = []

    if group:
        while len(group) < 4:
            group.append("00000013")  # NOP padding
        f.write("".join(group) + "\n")

