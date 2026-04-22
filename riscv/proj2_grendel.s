#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
#
# Software-scheduled for 5-stage in-order pipeline WITHOUT data forwarding.
# Pipeline stages: IF -> ID -> EX -> MEM -> WB
#
# HAZARD RULES APPLIED:
#   DATA: A register written by instruction P is available after its WB stage.
#         Any instruction that reads the register must have its ID stage AFTER P's WB.
#         With no forwarding this means the reader must be >= 3 positions after the
#         writer (2 instructions must be between every producer and consumer).
#   LOAD-USE: Same rule applies to loads (lw/lb). The load value comes from MEM stage
#         and is written in WB; consumers still need 2 instructions of gap.
#   STORE-LOAD (same address): A sw followed by a lw to the same address also needs
#         2 instructions of gap because the store writes memory at MEM stage and the
#         load reads memory at its own MEM stage; they must not overlap.
#   CONTROL: Branch/jump at position B: the instructions at B+1 and B+2 are always
#         fetched and begin executing. They are squashed on the taken path.
#         Fill with instructions that are useful on the not-taken path AND safe
#         (side-effect-free or correctly squashed) on the taken path.
#         Use NOP only when no such instruction is available.
#
# NOTE on 'la' pseudo-instruction:
#   RARS expands  la rd, label  to  lui rd, %hi(label) ; addi rd, rd, %lo(label)
#   The register rd is written by the SECOND (addi) instruction.
#   Count the la as consuming 2 instruction slots; rd is ready after those 2 slots.
#   One more gap slot is then needed before rd is consumed (standard 2-gap rule
#   applies from the end of the la expansion).
#
# ANNOTATION:
#   [Dx/2]  = data hazard delay slot x of 2  (* = filled with real instruction)
#   [Cx/2]  = control hazard delay slot x of 2  (* = filled with real instruction)
#   Unannotated NOPs are unavoidable stalls with no independent instruction available.
#
# Expected result: first 4 words of data segment = [3, 0, 2, 1]
#

.data
res:
        .word -1-1-1-1
nodes:
        .byte   97                  # a
        .byte   98                  # b
        .byte   99                  # c
        .byte   100                 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
        .byte 0 0 0 0
res_idx:
        .word   3

.text
        li    sp, 0x10011000
        li    fp, 0
        la    ra, pump
        j     main
        nop                         # [C1/2]
        nop                         # [C2/2]
pump:
        j     end
        nop                         # [C1/2]
        nop                         # [C2/2]
        ebreak


# ================================================================
#  main
# ================================================================
main:
        addi  sp, sp, -40           # sp = stack top
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    ra, 36(sp)            # save ra; sp ready (gap=2)
        sw    fp, 32(sp)            # save fp; independent *
        add   fp, sp, x0            # fp = sp
        # fp written here; next use of fp is sw x0,24(fp).
        # gap = 1 -> HAZARD. Need 2 instrs between add fp and sw fp.
        # sw x0,24(sp) uses sp not fp - safe to schedule here:
        nop                         # [D1/2 for add fp] (no safe sp-only instr available)
        nop                         # [D2/2 for add fp]
        sw    x0, 24(fp)            # zero loop counter; fp ready (gap=2)
        j     main_loop_control
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  main_loop_body
# ================================================================
main_loop_body:
        lw    t4, 24(fp)            # t4 = loop index i
        la    ra, trucks            # [D1/2 for lw t4] * la fills one slot (lui instr)
                                    # la's addi is the 2nd slot -> [D2/2] *
        j     is_visited            # t4 ready: lw(0), la(1,2), j(3) -> gap=3 OK
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  trucks  (return from is_visited in outer loop; t2 = result byte)
# ================================================================
trucks:
        xori  t2, t2, 1             # t2 = flip LSB
        nop                         # [D1/2 for xori t2]
        nop                         # [D2/2 for xori t2]
        andi  t2, t2, 0xff          # t2 = low byte only
        nop                         # [D1/2 for andi t2]
        nop                         # [D2/2 for andi t2]
        beq   t2, x0, kick          # if already visited (result was 1->0 after xori), skip

        # Not visited: call topsort(i).
        # Two control slots after beq: fill with topsort argument setup.
        # On taken path (go to kick): lw t4 and la ra are squashed. Safe: kick
        # only uses t2 and fp, not t4 or ra set here.
        # On not-taken path: both execute correctly before topsort.
        lw    t4, 24(fp)            # [C1/2] * t4 = node index for topsort
        la    ra, billowy           # [C2/2] * set return address
        # NOTE: la in ctrl slot C2 = lui executes in slot C2, addi executes in C3.
        # C3 is NOT squashed (only C1 and C2 are squashed on taken branch).
        # On not-taken path: lui(C2) + addi(C3) both execute, ra correctly set. OK.
        # On taken path: lui(C2) is squashed, addi(C3) never runs. ra unchanged. OK.
        # t4: written by lw in slot C1. topsort reads t4 in ID stage.
        # j topsort is at position C3+1. t4 read in j's ID = C3+2.
        # lw t4 WB = C1+4. Need C3+2 >= C1+4 -> 2 >= 1+4-1 = trivially met since
        # the j itself plus the 2 ctrl slots of j give enough distance.
        # Actually: lw at pos 0, j topsort at pos 3 (lw,la(2),j). j's ID is at pipeline
        # cycle 4. lw WB at cycle 4. Simultaneous -> depends on clock edge. Add 1 NOP.
        j     topsort
        nop                         # [C1/2] gap also ensures t4 from lw in trucks is ready
        nop                         # [C2/2]
billowy:
        # return from topsort - fall through to kick (loop increment)


# ================================================================
#  kick  (outer loop increment)
# ================================================================
kick:
        lw    t2, 24(fp)            # t2 = i
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t2, t2, 1             # i++
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        sw    t2, 24(fp)            # store i back; t2 ready (gap=2)
        # fall through to main_loop_control


# ================================================================
#  main_loop_control
# ================================================================
main_loop_control:
        lw    t2, 24(fp)            # t2 = i
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        slti  t2, t2, 4             # t2 = (i < 4)
        nop                         # [D1/2 for slti t2]
        nop                         # [D2/2 for slti t2]
        beq   t2, x0, hew           # if i >= 4, exit loop (go to hew)
        j     main_loop_body        # [C1/2] * loop back; squashed if branch taken (safe)
        nop                         # [C2/2]


# ================================================================
#  hew  (outer loop done; initialize second pass)
# ================================================================
hew:
        sw    x0, 28(fp)            # fp[28] = 0 (second loop counter)
        j     welcome
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  wave  (second loop increment)
# ================================================================
wave:
        lw    t2, 28(fp)            # t2 = j
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t2, t2, 1             # j++
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        sw    t2, 28(fp)            # store j back
        # fall through to welcome


# ================================================================
#  welcome  (second loop control)
# ================================================================
welcome:
        lw    t2, 28(fp)            # t2 = j
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        slti  t2, t2, 4             # t2 = (j < 4)
        nop                         # [D1/2 for slti t2]
        nop                         # [D2/2 for slti t2]
        xori  t2, t2, 1             # t2 = !(j < 4)
        nop                         # [D1/2 for xori t2]
        nop                         # [D2/2 for xori t2]
        beq   t2, x0, wave          # if j < 4, loop back

        # Loop done: two ctrl slots - fill with independent epilogue work.
        # On taken path (go to wave): mv t2 squashed (safe), mv sp squashed (sp unchanged->safe).
        # On not-taken: both execute and are needed.
        mv    t2, x0               # [C1/2] * clear return value
        mv    sp, fp               # [C2/2] * restore sp from fp
        # sp just written by mv sp,fp (in ctrl slot C2). Next use of sp is lw ra,36(sp).
        # mv sp in C2 = pos 0 (relative). lw ra = pos 1. Gap=1 -> HAZARD.
        nop                         # gap for mv sp,fp -> lw ra
        nop                         # gap for mv sp,fp -> lw ra
        lw    ra, 36(sp)            # sp ready (gap=2 from mv sp,fp)
        lw    fp, 32(sp)            # [D1/2 for lw ra] * independent restore
        nop                         # [D2/2 for lw ra]
        addi  sp, sp, 40            # independent of ra
        jr    ra                    # ra: lw(0),lw fp(1),nop(2),addi(3),jr(4) -> gap=4 OK
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  interest  (inner loop body of topsort; calls is_visited)
# ================================================================
interest:
        lw    t4, 24(fp)            # t4 = current node (edge index from struct)
        la    ra, new               # [D1/2 for lw t4] * la fills both data slots
        j     is_visited            # [D2/2 for lw t4] * (la = 2 instrs, j = 3rd)
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  new  (return from is_visited in inner loop; t2 = result)
# ================================================================
new:
        xori  t2, t2, 1
        nop                         # [D1/2 for xori t2]
        nop                         # [D2/2 for xori t2]
        andi  t2, t2, 0x0ff
        nop                         # [D1/2 for andi t2]
        nop                         # [D2/2 for andi t2]
        beq   t2, x0, tasteful      # if not visited, advance to tasteful

        # Visited: recurse topsort on this neighbor.
        # Fill ctrl slots with topsort setup (safe to squash on taken path):
        lw    t4, 24(fp)            # [C1/2] * load node index
        la    ra, partner           # [C2/2] * set return addr
        j     topsort
        nop                         # [C1/2] (also ensures t4 from lw is ready for topsort)
        nop                         # [C2/2]
partner:
        # return from topsort - fall through to tasteful


# ================================================================
#  tasteful  (advance edge iterator)
# ================================================================
tasteful:
        addi  t2, fp, 28            # t2 = &edge_struct (fp+28)
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        mv    t4, t2                # t4 = edge_struct ptr
        la    ra, badge             # [D1/2 for mv t4] * fills data slot
        j     next_edge             # [D2/2 for mv t4] * t4: mv(0),la(1,2),j(3) gap=3 OK
        nop                         # [C1/2]
        nop                         # [C2/2]
badge:
        sw    t2, 24(fp)            # store result back (t2 from next_edge return)
        # fall through to turkey


# ================================================================
#  turkey  (check if inner loop done: result == -1 means done)
# ================================================================
turkey:
        lw    t3, 24(fp)            # t3 = current edge value
        li    t2, -1                # [D1/2 for lw t3] * independent sentinel load
        nop                         # [D2/2 for lw t3]
        nop                         # [D for li t2]: li(pos1), beq reads t2 at pos4: gap=3 OK
        beq   t3, t2, telling       # if t3 == -1, all edges processed
        # t3: lw(0), li(1), nop(2), nop(3), beq(4) -> gap=4 OK
        # t2: li(1), nop(2), nop(3), beq(4) -> gap=3 OK
        j     interest              # [C1/2] * loop back to inner loop
        nop                         # [C2/2]


# ================================================================
#  telling  (record current node in result array, then return)
# ================================================================
telling:
        la    t2, res_idx           # t2 = &res_idx
        nop                         # [D1/2 for la t2] (after la's addi)
        nop                         # [D2/2 for la t2]
        lw    t2, 0(t2)             # t2 = res_idx value; t2 addr ready (gap=2)
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t4, t2, -1            # t4 = res_idx - 1
        la    t3, res_idx           # [D1/2 for addi t4] * fills slot (lui part of la)
        nop                         # [D2/2 for addi t4] (la addi runs here)
        # t4: addi(0), la(1,2), nop... we need 2 slots after addi before sw.
        # addi(0), la-lui(1), la-addi(2). sw at (3): gap(addi t4, sw) = 3. OK.
        # t3: la addi at pos 2, sw at pos 3: gap = 1. HAZARD on t3!
        # Need 1 more instruction between la's addi and sw t4,0(t3).
        nop                         # extra gap for t3 (la addi at 2, nop at 3, sw at 4)
        sw    t4, 0(t3)             # res_idx--; t4 gap=4 OK, t3 gap=2 OK

        # Compute address in res[]: res + res_idx*4
        # t2 still holds original res_idx value.
        slli  t3, t2, 2             # t3 = res_idx * 4
        # (Original 4-instruction shift chain slli/srli/srai/slli reduces to slli 2.
        #  The xor/or/neg on t6 are also dead code and omitted.)
        la    t2, res               # [D1/2 for slli t3] * fills data slot
        li    a1, 0x0000ffff        # [D2/2 for slli t3] * fills data slot
        # t2 from la: la-lui at D1, la-addi at D2. t2 ready after la-addi.
        # t3 from slli: gap = slli(0),la(1,2),li(3)... t3 used at 'and' below.
        # and reads t2 (from la) and a1 (from li).
        # t2: la-addi at pos 2, and needs gap of 2 -> and at pos 4 min.
        # a1: li at pos 3, and at pos 4: gap=1 HAZARD. Need and at pos 5.
        nop                         # gap for a1 (li at 3, nop at 4, and at 5: gap=2 OK)
        nop                         # extra gap (and at pos 5, t2 gap from la-addi = 3 OK)
        and   t6, t2, a1            # t6 = low 16 bits of &res
        nop                         # [D1/2 for and t6]
        nop                         # [D2/2 for and t6]
        add   t2, t4, t6            # t2 = (res_idx-1) + low16(&res)
        nop                         # [D1/2 for add t2]
        nop                         # [D2/2 for add t2]
        add   t2, t3, t2            # t2 = &res[res_idx] (final address)
        nop                         # [D1/2 for add t2 (2nd)]
        nop                         # [D2/2 for add t2 (2nd)]
        lw    t3, 48(fp)            # t3 = node value to store; independent of t2
        nop                         # [D1/2 for lw t3]
        nop                         # [D2/2 for lw t3]
        sw    t3, 0(t2)             # res[res_idx] = node; t2 gap >> 2 OK, t3 gap=2 OK

        # Epilogue
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    ra, 44(sp)            # sp ready (gap=2)
        lw    fp, 40(sp)            # [D1/2 for lw ra] * independent restore
        nop                         # [D2/2 for lw ra]
        addi  sp, sp, 48            # independent
        jr    ra                    # ra: lw(0),lw fp(1),nop(2),addi(3),jr(4) gap=4 OK
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  topsort  (DFS visit a node: mark visited, iterate edges, recurse)
#  t4 = node index
# ================================================================
topsort:
        addi  sp, sp, -48
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    ra, 44(sp)            # sp ready (gap=2)
        sw    fp, 40(sp)            # independent *
        mv    fp, sp                # fp = sp
        nop                         # [D1/2 for mv fp]
        nop                         # [D2/2 for mv fp]
        sw    t4, 48(fp)            # fp ready (gap=2)
        nop                         # [D1/2 for sw] (sw-then-lw same addr needs gap)
        nop                         # [D2/2 for sw]
        lw    t4, 48(fp)            # reload t4 from frame; gap=2 from sw OK
        la    ra, verse             # [D1/2 for lw t4] * fills data slot
        j     mark_visited          # [D2/2 for lw t4] * t4: lw(0),la(1,2),j(3) gap=3 OK
        nop                         # [C1/2]
        nop                         # [C2/2]
verse:
        # Return from mark_visited. Set up iterate_edges(fp+28, node_idx).
        addi  t2, fp, 28            # t2 = edge struct in frame
        lw    t5, 48(fp)            # [D1/2 for addi t2] * t5 = node_idx; fills slot
        nop                         # [D2/2 for addi t2]
        mv    t4, t2                # t4 = edge struct ptr; t2: addi(0),lw(1),nop(2),mv(3) gap=3 OK
        la    ra, joyous            # [D1/2 for mv t4] * fills data slot
        j     iterate_edges         # [D2/2 for mv t4] * t4: mv(0),la(1,2),j(3) gap=3 OK
        nop                         # [C1/2]
        nop                         # [C2/2]
joyous:
        # Return from iterate_edges. Set up next_edge call.
        addi  t2, fp, 28            # t2 = edge struct ptr
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        mv    t4, t2                # t4 = ptr; t2 gap=2 OK
        la    ra, whispering        # [D1/2 for mv t4] * fills slot
        j     next_edge             # [D2/2 for mv t4] * gap=3 OK
        nop                         # [C1/2]
        nop                         # [C2/2]
whispering:
        sw    t2, 24(fp)            # update edge pointer in frame
        j     turkey
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  iterate_edges  (initialize edge struct: {node_ptr, 0})
#  t4 = pointer to struct, t5 = node index
# ================================================================
iterate_edges:
        addi  sp, sp, -24
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    fp, 20(sp)            # sp ready (gap=2)
        mv    fp, sp                # fp = sp
        nop                         # [D1/2 for mv fp]
        nop                         # [D2/2 for mv fp]
        sub   t6, fp, sp            # fp ready (gap=2); t6 = 0 (legacy, unused)
        sw    t4, 24(fp)            # store struct ptr; fp gap=3 (mv,nop,nop,sub,sw) OK
        sw    t5, 28(fp)            # store node_idx
        nop                         # [D1/2 for sw t5] (store-load same addr below)
        nop                         # [D2/2 for sw t5]
        lw    t2, 28(fp)            # reload node_idx; gap=2 from sw t5 OK
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        sw    t2, 8(fp)             # frame[8] = node_idx
        sw    x0, 12(fp)            # frame[12] = 0 (edge index init); independent *

        # Load struct pointer and initialize struct fields
        lw    t2, 24(fp)            # t2 = struct ptr
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        lw    t4, 8(fp)             # t4 = node_idx
        lw    t3, 12(fp)            # [D1/2 for lw t4] * t3 = 0 (edge index); fills slot
        nop                         # [D2/2 for lw t4]
        sw    t4, 0(t2)             # struct->node = node_idx; t4: lw(0),lw(1),nop(2),sw(3) gap=3 OK
                                    # t2: lw(0 from earlier),... gap >> 2 OK
        sw    t3, 4(t2)             # struct->edge_idx = 0; t3: lw(0),nop(1),sw(2) gap=2 OK
        lw    t2, 24(fp)            # return value = struct ptr

        # Epilogue
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    fp, 20(sp)            # sp ready (gap=2)
        nop                         # [D1/2 for lw fp]
        nop                         # [D2/2 for lw fp]
        addi  sp, sp, 24
        jr    ra
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  next_edge  (advance edge iterator; returns -1 when exhausted)
#  t4 = pointer to {node_idx, edge_idx}
# ================================================================
next_edge:
        addi  sp, sp, -32
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    ra, 28(sp)            # sp ready (gap=2)
        sw    fp, 24(sp)            # independent *
        add   fp, x0, sp            # fp = sp
        nop                         # [D1/2 for add fp]
        nop                         # [D2/2 for add fp]
        sw    t4, 32(fp)            # fp ready (gap=2)
        j     waggish               # check loop condition first
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  snail  (next_edge loop body: check if current edge exists)
# ================================================================
snail:
        lw    t2, 32(fp)            # t2 = &struct
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        lw    t3, 0(t2)             # t3 = struct->node_idx
        lw    t2, 32(fp)            # [D1/2 for lw t3] * reload &struct; fills slot
        nop                         # [D2/2 for lw t3]
        lw    t2, 4(t2)             # t2 = struct->edge_idx; t2(reload): lw(0),nop(1),lw(2) gap=2 OK
        nop                         # [D1/2 for lw t2 (edge_idx)]
        nop                         # [D2/2 for lw t2]
        mv    t5, t2                # t5 = edge_idx; t2 gap=2 OK
        mv    t4, t3                # [D1/2 for mv t5] * t4 = node_idx; fills slot
        la    ra, induce            # [D2/2 for mv t5] * fills slot; t5 gap: mv(0),mv(1),la(2,3),j=gap 4 OK
        j     has_edge
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  induce  (return from has_edge; t2 = 1 if edge exists, 0 if not)
# ================================================================
induce:
        # t2 comes from has_edge return. Need 2 gap before beq reads t2.
        nop                         # [D1/2 for t2 from has_edge]
        nop                         # [D2/2 for t2]
        beq   t2, x0, quarter       # no edge -> go to quarter

        # Edge exists: increment struct->edge_idx and loop back.
        # Ctrl slots after beq:
        lw    t2, 32(fp)            # [C1/2] * t2 = &struct
        nop                         # [C2/2] cannot chain lw t2,4(t2) here (t2 gap=1 HAZARD)
        nop                         # [D1/2 for lw t2 from ctrl slot]
        nop                         # [D2/2 for lw t2]
        lw    t2, 4(t2)             # t2 = struct->edge_idx
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t4, t2, 1             # t4 = edge_idx + 1
        lw    t3, 32(fp)            # [D1/2 for addi t4] * &struct; fills slot
        nop                         # [D2/2 for addi t4]
        sw    t4, 4(t3)             # struct->edge_idx++; t4 gap=3 OK, t3 gap=2 OK
        j     cynical
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  quarter  (no edge found: still advance edge_idx, then re-check)
# ================================================================
quarter:
        lw    t2, 32(fp)            # t2 = &struct
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        lw    t2, 4(t2)             # t2 = struct->edge_idx
        nop                         # [D1/2 for lw t2 (2nd)]
        nop                         # [D2/2 for lw t2 (2nd)]
        addi  t3, t2, 1             # t3 = edge_idx + 1
        lw    t2, 32(fp)            # [D1/2 for addi t3] * fills slot
        nop                         # [D2/2 for addi t3]
        sw    t3, 4(t2)             # struct->edge_idx = t3; t3 gap=3 OK, t2 gap=2 OK
        # fall through to waggish


# ================================================================
#  waggish  (next_edge loop condition: while edge_idx < 4)
# ================================================================
waggish:
        lw    t2, 32(fp)            # t2 = &struct
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        lw    t2, 4(t2)             # t2 = struct->edge_idx
        nop                         # [D1/2 for lw t2 (2nd)]
        nop                         # [D2/2 for lw t2 (2nd)]
        slti  t2, t2, 4             # t2 = (edge_idx < 4)
        nop                         # [D1/2 for slti t2]
        nop                         # [D2/2 for slti t2]
        beq   t2, x0, mark          # if done, fall to mark (return -1)
        j     snail                 # [C1/2] * loop body; squashed if branch taken (safe)
        nop                         # [C2/2]


# ================================================================
#  mark  (exhausted all edges; set return value to -1)
# ================================================================
mark:
        li    t2, -1
        # fall through to cynical


# ================================================================
#  cynical  (next_edge epilogue)
# ================================================================
cynical:
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    ra, 28(sp)            # sp ready (gap=2)
        lw    fp, 24(sp)            # [D1/2 for lw ra] * independent restore
        nop                         # [D2/2 for lw ra]
        addi  sp, sp, 32            # independent
        jr    ra                    # ra: lw(0),lw fp(1),nop(2),addi(3),jr(4) gap=4 OK
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  has_edge  (check adjacencymatrix[node][edge_idx])
#  t4 = node_idx, t5 = edge_idx
#  Returns t2 = 1 if edge exists, 0 otherwise
# ================================================================
has_edge:
        addi  sp, sp, -32
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    fp, 28(sp)            # sp ready (gap=2)
        mv    fp, sp                # fp = sp
        nop                         # [D1/2 for mv fp]
        nop                         # [D2/2 for mv fp]
        sw    t4, 32(fp)            # fp ready (gap=2)
        sw    t5, 36(fp)            # independent *

        la    t2, adjacencymatrix   # t2 = base addr of adjacency matrix
        lw    t3, 32(fp)            # [D1/2 for la t2] * t3 = node_idx; fills slot
        nop                         # [D2/2 for la t2] (la addi runs here; t2 ready after)
        slli  t3, t3, 2             # t3 = node_idx * 4; t3: lw(1),nop(2),slli(3) gap=2 OK
        nop                         # [D1/2 for slli t3]
        nop                         # [D2/2 for slli t3]
        add   t2, t3, t2            # t2 = &adjacencymatrix[node_idx]
        nop                         # [D1/2 for add t2]
        nop                         # [D2/2 for add t2]
        lw    t2, 0(t2)             # t2 = adjacency row (bit-packed edges)
        sw    t2, 16(fp)            # [D1/2 for lw t2] * store to frame; fills slot
        nop                         # [D2/2 for lw t2]

        li    t2, 1                 # t2 = mask = 1
        sw    t2, 8(fp)             # [D1/2 for li t2] * store mask
        nop                         # [D2/2 for li t2]
        sw    x0, 12(fp)            # bit_index = 0; independent *
        j     measley
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  look  (has_edge loop body: shift mask left, increment bit index)
# ================================================================
look:
        lw    t2, 8(fp)             # t2 = mask
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        slli  t2, t2, 1             # mask <<= 1
        nop                         # [D1/2 for slli t2]
        nop                         # [D2/2 for slli t2]
        sw    t2, 8(fp)             # store mask (sw has no register output)
        lw    t2, 12(fp)            # * independent load (reads fp, not t2); fills a slot
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t2, t2, 1             # bit_index++
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        sw    t2, 12(fp)            # store bit_index
        # fall through to measley


# ================================================================
#  measley  (has_edge loop condition: while bit_index < edge_idx)
# ================================================================
measley:
        lw    t3, 12(fp)            # t3 = bit_index
        lw    t2, 36(fp)            # [D1/2 for lw t3] * t2 = edge_idx; fills slot
        nop                         # [D2/2 for lw t3]
        slt   t2, t3, t2            # t2 = (bit_index < edge_idx); t3 gap=3 OK, t2 gap=2 OK
        nop                         # [D1/2 for slt t2]
        nop                         # [D2/2 for slt t2]
        beq   t2, x0, experience    # if done, check result
        j     look                  # [C1/2] * loop back
        nop                         # [C2/2]


# ================================================================
#  experience  (has_edge: return 1 if the adjacency bit is set)
# ================================================================
experience:
        lw    t3, 8(fp)             # t3 = mask
        lw    t2, 16(fp)            # [D1/2 for lw t3] * t2 = adjacency row; fills slot
        nop                         # [D2/2 for lw t3]
        and   t2, t3, t2            # t2 = mask & adjacency_row; t3 gap=3 OK, t2 gap=2 OK
        nop                         # [D1/2 for and t2]
        nop                         # [D2/2 for and t2]
        slt   t2, x0, t2            # t2 = (result != 0) = 1 if edge exists
        nop                         # [D1/2 for slt t2]
        nop                         # [D2/2 for slt t2]
        andi  t2, t2, 0xff          # mask to byte

        # Epilogue
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    fp, 28(sp)            # sp ready (gap=2)
        nop                         # [D1/2 for lw fp]
        nop                         # [D2/2 for lw fp]
        addi  sp, sp, 32
        jr    ra
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  mark_visited  (set the visited flag for a node)
#  t4 = node index
# ================================================================
mark_visited:
        addi  sp, sp, -32
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    fp, 28(sp)            # sp ready (gap=2)
        mv    fp, sp
        nop                         # [D1/2 for mv fp]
        nop                         # [D2/2 for mv fp]
        sw    t4, 32(fp)            # fp ready (gap=2)
        li    t2, 1                 # mask = 1
        sw    t2, 8(fp)             # [D1/2 for li t2] * store initial mask
        nop                         # [D2/2 for li t2]
        sw    x0, 12(fp)            # bit_count = 0; independent *
        j     recast
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  example  (mark_visited loop body: shift mask by 8, inc count)
# ================================================================
example:
        lw    t2, 8(fp)             # t2 = mask
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        slli  t2, t2, 8             # mask <<= 8 (advance to next byte in word)
        nop                         # [D1/2 for slli t2]
        nop                         # [D2/2 for slli t2]
        sw    t2, 8(fp)             # store mask
        lw    t2, 12(fp)            # * independent load (reads fp addr, not t2 val)
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t2, t2, 1             # count++
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        sw    t2, 12(fp)            # store count
        # fall through to recast


# ================================================================
#  recast  (mark_visited loop condition: while count < node_idx)
# ================================================================
recast:
        lw    t3, 12(fp)            # t3 = count
        lw    t2, 32(fp)            # [D1/2 for lw t3] * t2 = node_idx; fills slot
        nop                         # [D2/2 for lw t3]
        slt   t2, t3, t2            # t2 = (count < node_idx); t3 gap=3 OK, t2 gap=2 OK
        nop                         # [D1/2 for slt t2]
        nop                         # [D2/2 for slt t2]
        beq   t2, x0, pat           # if count >= node_idx, done
        j     example               # [C1/2] * loop back
        nop                         # [C2/2]


# ================================================================
#  pat  (mark_visited: OR mask into visited[] word)
# ================================================================
pat:
        la    t2, visited           # t2 = &visited
        nop                         # [D1/2 for la t2]
        nop                         # [D2/2 for la t2]
        sw    t2, 16(fp)            # store &visited; t2 ready (gap=2 from la addi)
        nop                         # [D1/2 for sw] (store-load same addr below)
        nop                         # [D2/2 for sw]
        lw    t2, 16(fp)            # reload &visited; gap=2 from sw OK
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        lw    t3, 0(t2)             # t3 = visited word; t2 ready (gap=2)
        lw    t2, 8(fp)             # [D1/2 for lw t3] * t2 = mask; fills slot
        nop                         # [D2/2 for lw t3]
        or    t3, t3, t2            # t3 |= mask; t3 gap=3 OK, t2 gap=2 OK
        lw    t2, 16(fp)            # [D1/2 for or t3] * reload &visited; fills slot
        nop                         # [D2/2 for or t3]
        sw    t3, 0(t2)             # visited |= mask; t3 gap=3 OK, t2 gap=2 OK

        # Epilogue
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    fp, 28(sp)            # sp ready (gap=2)
        nop                         # [D1/2 for lw fp]
        nop                         # [D2/2 for lw fp]
        addi  sp, sp, 32
        jr    ra
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  is_visited  (check if node has already been visited)
#  t4 = node index
#  Returns t2 = 1 if visited, 0 otherwise
# ================================================================
is_visited:
        addi  sp, sp, -32
        nop                         # [D1/2 for addi sp]
        nop                         # [D2/2 for addi sp]
        sw    fp, 28(sp)            # sp ready (gap=2)
        mv    fp, sp
        nop                         # [D1/2 for mv fp]
        nop                         # [D2/2 for mv fp]
        sw    t4, 32(fp)            # fp ready (gap=2)
        ori   t2, x0, 1             # t2 = mask = 1
        sw    t2, 8(fp)             # [D1/2 for ori t2] * store mask
        nop                         # [D2/2 for ori t2]
        sw    x0, 12(fp)            # bit_count = 0; independent *
        j     evasive
        nop                         # [C1/2]
        nop                         # [C2/2]


# ================================================================
#  justify  (is_visited loop body: shift mask, inc count)
# ================================================================
justify:
        lw    t2, 8(fp)             # t2 = mask
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        slli  t2, t2, 8             # mask <<= 8
        nop                         # [D1/2 for slli t2]
        nop                         # [D2/2 for slli t2]
        sw    t2, 8(fp)             # store mask
        lw    t2, 12(fp)            # * independent load; fills a slot
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        addi  t2, t2, 1             # count++
        nop                         # [D1/2 for addi t2]
        nop                         # [D2/2 for addi t2]
        sw    t2, 12(fp)            # store count


# ================================================================
#  evasive  (is_visited loop condition: while count < node_idx)
# ================================================================
evasive:
        lw    t3, 12(fp)            # t3 = count
        lw    t2, 32(fp)            # [D1/2 for lw t3] * t2 = node_idx; fills slot
        nop                         # [D2/2 for lw t3]
        slt   t2, t3, t2            # t2 = (count < node_idx); t3 gap=3 OK, t2 gap=2 OK
        nop                         # [D1/2 for slt t2]
        nop                         # [D2/2 for slt t2]
        beq   t2, x0, representative
        j     justify               # [C1/2] * loop back
        nop                         # [C2/2]


# ================================================================
#  representative  (is_visited: test mask against visited word)
# ================================================================
representative:
        la    t2, visited           # t2 = &visited
        nop                         # [D1/2 for la t2]
        nop                         # [D2/2 for la t2]
        lw    t2, 0(t2)             # t2 = visited word; addr ready (gap=2 from la addi)
        nop                         # [D1/2 for lw t2]
        nop                         # [D2/2 for lw t2]
        sw    t2, 16(fp)            # save visited to frame
        nop                         # [D1/2 for sw] (store-load gap)
        nop                         # [D2/2 for sw]
        lw    t3, 16(fp)            # t3 = visited; gap=2 from sw OK
        lw    t2, 8(fp)             # [D1/2 for lw t3] * t2 = mask; fills slot
        nop                         # [D2/2 for lw t3]
        and   t2, t3, t2            # t2 = visited & mask; t3 gap=3 OK, t2 gap=2 OK
        nop                         # [D1/2 for and t2]
        nop                         # [D2/2 for and t2]
        slt   t2, x0, t2            # t2 = (visited & mask != 0)
        nop                         # [D1/2 for slt t2]
        nop                         # [D2/2 for slt t2]
        andi  t2, t2, 0xff          # mask to byte

        # Epilogue
        mv    sp, fp
        nop                         # [D1/2 for mv sp]
        nop                         # [D2/2 for mv sp]
        lw    fp, 28(sp)            # sp ready (gap=2)
        nop                         # [D1/2 for lw fp]
        nop                         # [D2/2 for lw fp]
        addi  sp, sp, 32
        jr    ra
        nop                         # [C1/2]
        nop                         # [C2/2]


end:
        wfi