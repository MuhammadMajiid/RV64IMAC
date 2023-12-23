vlog riscv_core_hazard_unit.sv riscv_core_hazard_unit_tb.sv riscv_core_hazard_unit_class.sv +cover -covercells
vsim -voptargs=+acc work.riscv_core_hazard_unit_tb -cover
add wave *
coverage save riscv_core_hazard_unit_tb.ucdb -onexit
run -all
vcover report riscv_core_hazard_unit_tb.ucdb -details -annotate -all