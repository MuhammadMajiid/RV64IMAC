# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BLOCK_OFFSET" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BLOCK_OFFSET_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "D_CORE_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "D_TAG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INDEX_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I_CORE_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I_TAG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STRB_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to update AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to validate AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BLOCK_OFFSET { PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to update BLOCK_OFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLOCK_OFFSET { PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to validate BLOCK_OFFSET
	return true
}

proc update_PARAM_VALUE.BLOCK_OFFSET_WIDTH { PARAM_VALUE.BLOCK_OFFSET_WIDTH } {
	# Procedure called to update BLOCK_OFFSET_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLOCK_OFFSET_WIDTH { PARAM_VALUE.BLOCK_OFFSET_WIDTH } {
	# Procedure called to validate BLOCK_OFFSET_WIDTH
	return true
}

proc update_PARAM_VALUE.D_CORE_DATA_WIDTH { PARAM_VALUE.D_CORE_DATA_WIDTH } {
	# Procedure called to update D_CORE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_CORE_DATA_WIDTH { PARAM_VALUE.D_CORE_DATA_WIDTH } {
	# Procedure called to validate D_CORE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.D_TAG_WIDTH { PARAM_VALUE.D_TAG_WIDTH } {
	# Procedure called to update D_TAG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_TAG_WIDTH { PARAM_VALUE.D_TAG_WIDTH } {
	# Procedure called to validate D_TAG_WIDTH
	return true
}

proc update_PARAM_VALUE.INDEX_WIDTH { PARAM_VALUE.INDEX_WIDTH } {
	# Procedure called to update INDEX_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INDEX_WIDTH { PARAM_VALUE.INDEX_WIDTH } {
	# Procedure called to validate INDEX_WIDTH
	return true
}

proc update_PARAM_VALUE.I_CORE_DATA_WIDTH { PARAM_VALUE.I_CORE_DATA_WIDTH } {
	# Procedure called to update I_CORE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_CORE_DATA_WIDTH { PARAM_VALUE.I_CORE_DATA_WIDTH } {
	# Procedure called to validate I_CORE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.I_TAG_WIDTH { PARAM_VALUE.I_TAG_WIDTH } {
	# Procedure called to update I_TAG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_TAG_WIDTH { PARAM_VALUE.I_TAG_WIDTH } {
	# Procedure called to validate I_TAG_WIDTH
	return true
}

proc update_PARAM_VALUE.STRB_WIDTH { PARAM_VALUE.STRB_WIDTH } {
	# Procedure called to update STRB_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STRB_WIDTH { PARAM_VALUE.STRB_WIDTH } {
	# Procedure called to validate STRB_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.BLOCK_OFFSET { MODELPARAM_VALUE.BLOCK_OFFSET PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLOCK_OFFSET}] ${MODELPARAM_VALUE.BLOCK_OFFSET}
}

proc update_MODELPARAM_VALUE.BLOCK_OFFSET_WIDTH { MODELPARAM_VALUE.BLOCK_OFFSET_WIDTH PARAM_VALUE.BLOCK_OFFSET_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLOCK_OFFSET_WIDTH}] ${MODELPARAM_VALUE.BLOCK_OFFSET_WIDTH}
}

proc update_MODELPARAM_VALUE.INDEX_WIDTH { MODELPARAM_VALUE.INDEX_WIDTH PARAM_VALUE.INDEX_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INDEX_WIDTH}] ${MODELPARAM_VALUE.INDEX_WIDTH}
}

proc update_MODELPARAM_VALUE.I_TAG_WIDTH { MODELPARAM_VALUE.I_TAG_WIDTH PARAM_VALUE.I_TAG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_TAG_WIDTH}] ${MODELPARAM_VALUE.I_TAG_WIDTH}
}

proc update_MODELPARAM_VALUE.I_CORE_DATA_WIDTH { MODELPARAM_VALUE.I_CORE_DATA_WIDTH PARAM_VALUE.I_CORE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_CORE_DATA_WIDTH}] ${MODELPARAM_VALUE.I_CORE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_DATA_WIDTH { MODELPARAM_VALUE.AXI_DATA_WIDTH PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.D_TAG_WIDTH { MODELPARAM_VALUE.D_TAG_WIDTH PARAM_VALUE.D_TAG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_TAG_WIDTH}] ${MODELPARAM_VALUE.D_TAG_WIDTH}
}

proc update_MODELPARAM_VALUE.D_CORE_DATA_WIDTH { MODELPARAM_VALUE.D_CORE_DATA_WIDTH PARAM_VALUE.D_CORE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_CORE_DATA_WIDTH}] ${MODELPARAM_VALUE.D_CORE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.STRB_WIDTH { MODELPARAM_VALUE.STRB_WIDTH PARAM_VALUE.STRB_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STRB_WIDTH}] ${MODELPARAM_VALUE.STRB_WIDTH}
}

