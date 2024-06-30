######################################################
######################################################
### Project: RV64IMAC                              ###
### Development Board: UltraScale Kintex-7 KCU105  ###
### Part : XCKU040-2FFVA1156E                      ###
### Purpose : Timing & Physical Constraints        ###
######################################################
######################################################


################# Timing Constarints #################


################ Physical Constarints ################
# System Clock Generation
# # Bank  45 VCCO - VCC1V2_FPGA_3A - IO_L12P_T1U_N10_GC_45
#set_property PACKAGE_PIN AK17            [get_ports "default_sysclk_300_clk_p"]
#set_property IOSTANDARD  DIFF_SSTL12     [get_ports "default_sysclk_300_clk_p"] 
#set_property ODT         RTT_48          [get_ports "default_sysclk_300_clk_p"] 
# # Bank  45 VCCO - VCC1V2_FPGA_3A - IO_L12N_T1U_N11_GC_45
#set_property PACKAGE_PIN AK16            [get_ports "default_sysclk_300_clk_n"] 
#set_property IOSTANDARD  DIFF_SSTL12     [get_ports "default_sysclk_300_clk_n"] 
#set_property ODT         RTT_48          [get_ports "default_sysclk_300_clk_n"]
# # Bank  66 VCCO - VADJ_1V8_FPGA_10A - IO_L12P_T1U_N10_GC_66
 set_property CFGBVS GND [current_design]
 set_property CONFIG_VOLTAGE 1.8 [current_design]
 set_property PACKAGE_PIN G10      [get_ports "sysclk_125_clk_p"] 
 set_property IOSTANDARD  LVDS     [get_ports "sysclk_125_clk_p"] 
# #
# # Bank  66 VCCO - VADJ_1V8_FPGA_10A - IO_L12N_T1U_N11_GC_66
 set_property PACKAGE_PIN F10      [get_ports "sysclk_125_clk_n"] 
 set_property IOSTANDARD  LVDS     [get_ports "sysclk_125_clk_n"]

# Push-Buttons
# # Bank  84 VCCO -          - IO_L16N_T2U_N7_QBC_AD3N_64
################################################################### ACTIVE-HIGH RESET
 set_property PACKAGE_PIN AE10     [get_ports "reset"] 
 set_property IOSTANDARD  LVCMOS18 [get_ports "reset"] 

# Switches
# # Bank  45 VCCO - VCC1V2_FPGA_3A - IO_L3N_T0L_N5_AD15N_45
################################################################### ACTIVE-LOW RESET
 set_property PACKAGE_PIN AN16      [get_ports "i_riscv_core_rst_n"] 
 set_property IOSTANDARD  LVCMOS12  [get_ports "i_riscv_core_rst_n"] 


# LEDs
# # Bank  84 VCCO -          - IO_L22N_T3U_N7_DBC_AD0N_64
#set_property PACKAGE_PIN AP8      [get_ports "o_riscv_core_uart_tx_busy"] 
#set_property IOSTANDARD  LVCMOS18 [get_ports "o_riscv_core_uart_tx_busy"] 


# PL-UART
# # Bank  95 VCCO -          - IO_L3P_T0L_N4_AD15P_A26_65
#set_property PACKAGE_PIN G25      [get_ports "o_riscv_core_uart_tx"]
#set_property IOSTANDARD  LVCMOS18 [get_ports "o_riscv_core_uart_tx"] 


#leds
set_property PACKAGE_PIN P20      [get_ports "for_leds[0]"]
set_property PACKAGE_PIN P21      [get_ports "for_leds[1]"]
set_property PACKAGE_PIN N22      [get_ports "for_leds[2]"]
set_property PACKAGE_PIN M22      [get_ports "for_leds[3]"]
set_property PACKAGE_PIN R23      [get_ports "for_leds[4]"]
set_property PACKAGE_PIN P23       [get_ports "for_leds[5]"]
set_property PACKAGE_PIN H23       [get_ports "for_leds[6]"]
#set_property PACKAGE_PIN DS7       [get_ports "for_leds[7]"]

set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[0]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[1]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[2]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[3]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[4]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[5]"]
set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[6]"]
#set_property IOSTANDARD  LVCMOS18       [get_ports "for_leds[7]"]

# # Bank  95 VCCO -          - IO_L2P_T0L_N2_FOE_B_65
#  set_property PACKAGE_PIN G25      [get_ports "o_riscv_core_uart_rx"] 
#  set_property IOSTANDARD  LVMOS18  [get_ports "o_riscv_core_uart_rx"] 