`include "ctrl.v"
module STALL(
    input [31:0] D_instruction,
    input [31:0] E_instruction,
    input [31:0] M_instruction,
    output stall
);

//只可能在 D 级进行阻塞，阻塞控制器接受 D，E，M 级的指令输入
    wire[3:0] Tuse_rs,Tuse_rt,Tnew_E,Tnew_M;
    wire[4:0] A3_E,A3_M;
    wire[4:0] D_rs,D_rt;
    wire D_sll_flag,D_branch,D_r_cal,D_i_cal,D_load,D_store,D_j_imm,D_j_reg,D_link,D_lui_flag;
    wire D_condition_branch_condition_link,E_condition_branch_condition_link,M_condition_branch_condition_link,W_condition_branch_condition_link;
    wire E_r_cal,E_i_cal,E_load,E_lui_flag;
    wire M_load;
    
    Control D_ctrl(
        .instruction(D_instruction),
        .rs(D_rs),
        .rt(D_rt),
        .sll_flag(D_sll_flag),
        .branch(D_branch),
        .r_cal(D_r_cal),
        .i_cal(D_i_cal),
        .load(D_load),
        .store(D_store),
        .j_imm(D_j_imm),
        .j_reg(D_j_reg),
        .link(D_link),
        .lui_flag(D_lui_flag),
        .condition_branch_condition_link(D_condition_branch_condition_link)
    );
    Control E_ctrl(
        .instruction(E_instruction),
        .GRFaddr(A3_E),
        .r_cal(E_r_cal),
        .i_cal(E_i_cal),
        .load(E_load),
        .lui_flag(E_lui_flag),
        .condition_branch_condition_link(E_condition_branch_condition_link)
    );
    Control M_ctrl(
        .instruction(M_instruction),
        .GRFaddr(A3_M),
        .load(M_load),
        .condition_branch_condition_link(M_condition_branch_condition_link)
    );

    assign Tuse_rs = (D_branch | D_j_reg | D_condition_branch_condition_link)                                                     ? 4'd0 :
                     ((D_r_cal & !D_sll_flag) | (D_i_cal & !D_lui_flag) | D_load | D_store)   ? 4'd1 : 4'd2;

    assign Tuse_rt = (D_branch | D_condition_branch_condition_link) ? 4'd0 : 
                     D_r_cal  ? 4'd1 :
                     D_store  ? 4'd2 : 4'd2;

    assign Tnew_E  = (E_i_cal  | E_r_cal) ? 4'd1 :
                     E_load                               ? 4'd2 : 4'd0;
                     
    assign Tnew_M  = M_load ? 4'd1 : 4'd0;
    //wire[3:0] Tuse_rs,Tuse_rt,Tnew_E,Tnew_M;
    wire E_stall_rs = (A3_E == D_rs && D_rs != 5'b0) && (Tnew_E > Tuse_rs);
    wire E_stall_rt = (A3_E == D_rt && D_rt != 5'b0) && (Tnew_E > Tuse_rt);
    wire M_stall_rs = (A3_M == D_rs && D_rs != 5'b0) && (Tnew_M > Tuse_rs);
    wire M_stall_rt = (A3_M == D_rt && D_rt != 5'b0) && (Tnew_M > Tuse_rt);

    assign stall = E_stall_rs | E_stall_rt | M_stall_rs | M_stall_rt;
    
endmodule