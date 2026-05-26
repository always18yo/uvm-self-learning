//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class spi_env #(type REQ = uvm_sequence_item,
                type RSP = uvm_sequence_item)
  extends uvm_env;

  `uvm_component_param_utils(spi_env #(REQ,RSP))

  apb_agent #(REQ,RSP) apb_agt;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agt = apb_agent #(REQ,RSP)::type_id::create("apb_agt", this);
  endfunction

endclass
