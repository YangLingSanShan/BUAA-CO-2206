`include "ctrl.v"
module STALL(
    input [31:0] D_instruction,
    input [31:0] E_instruction,
    input [31:0] M_instruction,
    input Busy,
    output stall
);

    wire[3:0] Tuse_rs,Tuse_rt,Tnew_E,Tnew_M;
    wire[4:0] A3_E,A3_M;
    wire[4:0] D_rs,D_rt;
    wire D_sll_flag,D_branch,D_r_cal,D_i_cal,D_load,D_store,D_j_imm,D_j_reg,D_link,D_lui_flag,D_Start,D_mf,D_mt;
    wire E_r_cal,E_i_cal,E_load,E_lui_flag,E_Start,E_mf,E_mt;
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
        .Start(D_Start),
        .move_to(D_mt),
        .move_from(D_mf)
    );
    Control E_ctrl(
        .instruction(E_instruction),
        .GRFaddr(A3_E),
        .r_cal(E_r_cal),
        .i_cal(E_i_cal),
        .load(E_load),
        .lui_flag(E_lui_flag),
        .Start(E_Start),
        .move_to(E_mt),
        .move_from(E_mf)
    );
    Control M_ctrl(
        .instruction(M_instruction),
        .GRFaddr(A3_M),
        .load(M_load)
    );

    assign Tuse_rs = (D_branch | D_j_reg)                                                            ? 4'd0 :
                     ((D_r_cal & !D_sll_flag) | (D_i_cal & !D_lui_flag) | D_load | D_store | D_mt)   ? 4'd1 : 4'd2;
    assign Tuse_rt = D_branch ? 4'd0 : 
                     D_r_cal  ? 4'd1 :
                     D_store  ? 4'd2 : 4'd2;
    assign Tnew_E  = (E_i_cal  | E_r_cal | E_mf)          ? 4'd1 :
                     E_load                               ? 4'd2 : 4'd0;
    assign Tnew_M  = M_load ? 4'd1 : 4'd0;
    //wire[3:0] Tuse_rs,Tuse_rt,Tnew_E,Tnew_M;
    wire E_stall_rs = (A3_E == D_rs && D_rs != 5'b0) && (Tnew_E > Tuse_rs);
    wire E_stall_rt = (A3_E == D_rt && D_rt != 5'b0) && (Tnew_E > Tuse_rt);
    wire M_stall_rs = (A3_M == D_rs && D_rs != 5'b0) && (Tnew_M > Tuse_rs);
    wire M_stall_rt = (A3_M == D_rt && D_rt != 5'b0) && (Tnew_M > Tuse_rt);
    wire MU_stall = (Busy | E_Start) && (D_Start | D_mt | D_mf);
    
    assign stall = E_stall_rs | E_stall_rt | M_stall_rs | M_stall_rt | MU_stall;
    
endmodule