module mul_float
  #(parameter
   FLOAT_WIDTH = 64
  )
  (
  input wire rst_n, clk, start,
  input wire [FLOAT_WIDTH - 1: 0] op1, op2,
  output reg [FLOAT_WIDTH - 1: 0] out_reg,
  output reg nan_reg,
  output reg overflow_reg,
  output reg underflow_reg,
  output reg zero_reg,
  output reg done_reg
  );
  localparam EXP_WIDTH = (FLOAT_WIDTH == 64) ? 11: 8; 
  localparam FRACTION_WIDTH = (FLOAT_WIDTH == 64) ? 52: 23;
  localparam FULL_FRACTION_WIDTH = FRACTION_WIDTH + 3;
  localparam SIGN_BIT =  FLOAT_WIDTH - 1;
  localparam EXP_MSB = SIGN_BIT - 1;
  localparam EXP_LSB = EXP_MSB - EXP_WIDTH + 1;
  localparam EXP_SHIFT = (2 ** (EXP_WIDTH - 1)) - 1;
  localparam EXP_MAX = (2 ** (EXP_WIDTH)) - 1;
  localparam FRACTION_MSB = EXP_LSB - 1;
  localparam NAN_VALUE = (FLOAT_WIDTH == 64) ? 64'h7FF8_0000_0000_0000: 32'hFFC0_0000;
  localparam INF_VALUE = (FLOAT_WIDTH == 64) ? 64'h7FF0_0000_0000_0000: 32'h7F80_0000;
  localparam PRODUCT_WIDTH = (FRACTION_WIDTH + 1) * 2;
  localparam STAGE_REG_WIDTH = 2;
  localparam MAX_STAGE_REG = 2;
  
  wire [EXP_WIDTH - 1: 0] exp1 = op1[EXP_MSB: EXP_LSB],
    exp2 = op2[EXP_MSB: EXP_LSB];
	
  wire [FRACTION_WIDTH: 0] frac1 = {1'b1, op1[FRACTION_MSB: 0]},
  frac2 = {1'b1, op2[FRACTION_MSB: 0]};
  
  reg [STAGE_REG_WIDTH - 1: 0] stage_reg;
  wire [STAGE_REG_WIDTH - 1: 0] next_stage = stage_reg + 1;
  
  always@(posedge clk or negedge rst_n)
  begin: stage_inc
    if(!rst_n)
	   stage_reg <= 0;
	 else
	 begin
	   if(start)
		  stage_reg <= 0;
		else if(stage_reg < MAX_STAGE_REG)
        stage_reg <= next_stage;
    end
  end

  reg [EXP_WIDTH + 1: 0] full_exp_sum_reg, full_exp_sum_after_correction_reg; //full exp sum has two additional bits
  reg [PRODUCT_WIDTH - 1: 0] full_frac_reg;
  reg [FRACTION_WIDTH + 1: 0] frac_res_before_rounding_reg;
 
  always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
	 begin

	 end
	 else
    begin
	   if(stage_reg == 0)
		begin
	     full_exp_sum_reg <= exp1 + exp2 - EXP_SHIFT;
	     full_frac_reg <= frac1 * frac2; 
		end
		else if(stage_reg == 1)
		begin
		  //exp correction must be undertaken
		  full_exp_sum_after_correction_reg <= full_exp_sum_reg + full_frac_reg[PRODUCT_WIDTH - 1];
		  frac_res_before_rounding_reg <= full_frac_reg[PRODUCT_WIDTH - 1]? full_frac_reg[PRODUCT_WIDTH - 1: PRODUCT_WIDTH - FRACTION_WIDTH - 2] : full_frac_reg[PRODUCT_WIDTH - 2: PRODUCT_WIDTH - FRACTION_WIDTH - 3];
		end
		// it is not the end...
	 end
  end

  wire [FRACTION_WIDTH + 1: 0] frac_res_after_rounding = frac_res_before_rounding_reg + 1;
  wire [FRACTION_WIDTH - 1: 0] frac_res = frac_res_after_rounding[FRACTION_WIDTH: 1];
  wire sign1 = op1[SIGN_BIT],
    sign2 = op2[SIGN_BIT];
  wire sign_res = sign1 ^ sign2;
  wire [EXP_WIDTH - 1: 0] exp_res = full_exp_sum_after_correction_reg[EXP_WIDTH - 1: 0]; 
  wire 
  is_zero1 = (op1 & INF_VALUE) == 0,
  is_zero2 = (op2 & INF_VALUE) == 0,
  is_nan1 = &exp1 && (op1[FRACTION_WIDTH - 1: 0] != 0),
  is_nan2 = &exp2 && (op2[FRACTION_WIDTH - 1: 0] != 0),
  is_inf1 = &exp1 && (op1[FRACTION_WIDTH - 1: 0] == 0),
  is_inf2 = &exp2 && (op2[FRACTION_WIDTH - 1: 0] == 0),
  is_inf_result = (full_exp_sum_after_correction_reg[EXP_WIDTH + 1: EXP_WIDTH] == 2'b01) || ((full_exp_sum_after_correction_reg[EXP_WIDTH + 1: EXP_WIDTH] == 2'b00) && (&full_exp_sum_after_correction_reg[EXP_WIDTH - 1: 0])),
  is_nan_result = is_nan1 || is_nan2 || (is_zero1 && is_inf2) || (is_inf1 && is_zero2),
  is_overflow_result = is_inf_result && !(is_inf1 || is_inf2) && !is_nan_result,
  is_underflow_result = (full_exp_sum_after_correction_reg[EXP_WIDTH + 1] || (exp_res == 0)) && !(is_zero1 || is_zero2) && !is_overflow_result && !is_nan_result,
  is_zero_result = (is_zero1 || is_zero2 || (exp_res == 0) || is_underflow_result) && !is_overflow_result && !is_nan_result;
  
  always@(posedge clk or negedge rst_n)
  begin: result_out
    if(!rst_n)
	 begin
      out_reg <= 0;
	 end
	 else
    if(stage_reg == 2)
    begin
	   if(is_nan_result)
		begin
		  out_reg <= NAN_VALUE;
		end
		else if(is_zero_result)
		begin
		  out_reg <= {sign_res, {(FRACTION_WIDTH + EXP_WIDTH){1'b0}}};
		end
		else if(is_inf_result)
		begin
		  out_reg <= {sign_res,  {EXP_WIDTH{1'b1}}, {FRACTION_WIDTH{1'b0}}};
		end
		else
		begin
	     out_reg <= {sign_res, exp_res, frac_res};
		end
	 end
  end
  
  always@(posedge clk or negedge rst_n)
  begin: done_out
    if(!rst_n)
	 begin
      done_reg <= 0;
	 end
	 else
	 begin
      done_reg <= stage_reg == MAX_STAGE_REG; //done
    end
  end  
  
  always@(posedge clk or negedge rst_n)
  begin: aux_outs
    if(!rst_n)
	 begin
      nan_reg <= 0;
      overflow_reg <= 0;
      underflow_reg <= 0;
      zero_reg <= 0;
	 end
	 else
	 begin
      if(stage_reg == 2)
		begin
		  nan_reg <= is_nan_result;
        overflow_reg <= is_overflow_result;
        underflow_reg <= is_underflow_result;
        zero_reg <= is_zero_result;
		end
    end
  end  
  
endmodule
