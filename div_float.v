module div_float
  #(parameter
   FLOAT_WIDTH = 64
  )
  (
  input wire rst_n, clk, start,
  input wire [FLOAT_WIDTH - 1: 0] op1, op2,
  output reg [FLOAT_WIDTH - 1: 0] out_reg,
  output reg divizion_by_zero_reg,
  output reg nan_reg,
  output reg overflow_reg,
  output reg underflow_reg,
  output reg zero_reg,
  output reg done_reg
  );
  localparam EXP_WIDTH = (FLOAT_WIDTH == 64) ? 11: 8; 
  localparam FRACTION_WIDTH = (FLOAT_WIDTH == 64) ? 52: 23;
  localparam FULL_FRACTION_WIDTH = 2 * FRACTION_WIDTH + 1;
  localparam SIGN_BIT =  FLOAT_WIDTH - 1;
  localparam EXP_MSB = SIGN_BIT - 1;
  localparam EXP_LSB = EXP_MSB - EXP_WIDTH + 1;
  localparam EXP_SHIFT = (2 ** (EXP_WIDTH - 1)) - 1;
  localparam EXP_MAX = (2 ** (EXP_WIDTH)) - 1;
  localparam FRACTION_MSB = EXP_LSB - 1;
  localparam DIV_COUNTER_WIDTH = (FLOAT_WIDTH == 64) ? 7: 6;
  localparam NAN_VALUE = (FLOAT_WIDTH == 64) ? 64'hFFF8_0000_0000_0000: 32'hFFC0_0000;
  localparam INF_VALUE = (FLOAT_WIDTH == 64) ? 64'h7FF0_0000_0000_0000: 32'h7F80_0000;

  wire [FRACTION_MSB: 0] frac1 = op1[FRACTION_MSB: 0],
   frac2 = op2[FRACTION_MSB: 0];
  
  reg [FRACTION_WIDTH: 0] result_frac_reg;

  reg [FULL_FRACTION_WIDTH - 1: 0] op1frac_stage_reg, op2frac_stage_reg;
  wire op2_aligned = frac1 < frac2;
  // exponent calculation
  wire [EXP_WIDTH - 1: 0] exp1 = op1[EXP_MSB: EXP_LSB],
    exp2 = op2[EXP_MSB: EXP_LSB];

  wire [EXP_WIDTH: 0] result_exp_before_correction, temp_result;

  reg [EXP_WIDTH: 0] result_exp_reg;

  wire zero1 = exp1 == 0,
  exp1_max = exp1 == EXP_MAX,
  frac1_zero = frac1 == 0,
  inf1 = exp1_max & frac1_zero,
  nan1 = exp1_max & !frac1_zero,
  zero2 = exp2 == 0,
  exp2_max = exp2 == EXP_MAX,
  frac2_zero = frac2 == 0,
  inf2 = exp2_max & frac2_zero,
  nan2 = exp2_max & !frac2_zero,
  inf_out = zero2 & (!(nan1 | zero1)),
  zero_out = zero1 & (!(nan2 | zero1)),
  underflow_before_correction = (temp_result < exp2),
  zero_before_correction = result_exp_before_correction == 0;
  
  assign 
    temp_result = EXP_SHIFT + exp1,
    result_exp_before_correction = temp_result - exp2;

  always@*
  begin
    if(underflow_reg) begin
      result_exp_reg = 0;
    end
    else if (overflow_reg) begin
      result_exp_reg = EXP_MAX;
    end
    else 
    begin
      result_exp_reg = result_exp_before_correction - op2_aligned;
    end
  end
  //--------------------
  // fractional calculation
  reg [DIV_COUNTER_WIDTH   - 1: 0] div_counter_reg;
  wire sign1 = op1[SIGN_BIT],
  sign2 = op2[SIGN_BIT],
  result_sign = sign1 ^ sign2;
  
  always@*
  begin
    overflow_reg = result_exp_reg[EXP_WIDTH];
    underflow_reg = underflow_before_correction || (zero_before_correction && op2_aligned); 
    nan_reg = nan1 | nan2 | (inf1 & inf2) | (zero1 & zero2);
  end
  
  always@(negedge rst_n, posedge clk)
  begin
    if(!rst_n)
    begin
      op1frac_stage_reg <= 0;
      op2frac_stage_reg <= 0;
      div_counter_reg <= 0;
      result_frac_reg <= 0;
      done_reg <= 0;
    end
    else
    begin
      if(start)
      begin
        op1frac_stage_reg <= 0;
        op2frac_stage_reg <= 0;
        div_counter_reg <= 0;
        result_frac_reg <= 0;
        done_reg <= 0;
      end
      else 
      begin
        if(div_counter_reg == 0)
        begin
          op1frac_stage_reg <= {1'b1, frac1, {FRACTION_WIDTH {1'b0}}};
          op2frac_stage_reg <= (op2_aligned)? {2'b01, frac2[FRACTION_MSB: 0], {FRACTION_WIDTH - 1 {1'b0}}}: {1'b1, frac2, {FRACTION_WIDTH {1'b0}}};
        end
        else
        begin
		  if(div_counter_reg < FRACTION_WIDTH + 3)
          begin
            if(op1frac_stage_reg >= op2frac_stage_reg && op1frac_stage_reg != 0)
            begin
              op1frac_stage_reg <= op1frac_stage_reg - op2frac_stage_reg;
              result_frac_reg <= {result_frac_reg[FRACTION_WIDTH - 1: 0], 1'b1};
            end
            else
            begin
              result_frac_reg <= {result_frac_reg[FRACTION_WIDTH - 1: 0], 1'b0};
            end
            op2frac_stage_reg <= op2frac_stage_reg >> 1;
          end  
          else
          begin
            if(nan_reg)
            begin
              out_reg <= NAN_VALUE;
            end
            else if(inf_out)
              begin
                out_reg <= INF_VALUE | (result_sign << SIGN_BIT);            
              end
              else if(zero_out)
                begin
                  out_reg <= 0;
                end
                else
                begin
				  out_reg <= {result_sign, result_exp_reg[EXP_WIDTH - 1: 0], result_frac_reg[FRACTION_WIDTH: 1]};
                end
            div_counter_reg <= 0;
            done_reg <= 1;
          end
        end  
        div_counter_reg <= div_counter_reg + 1'b1;  
      end
    end
  end
endmodule
