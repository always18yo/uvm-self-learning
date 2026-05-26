//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//
//***************************************************************************************************************
class apb_agent #(type REQ = uvm_sequence_item,
                  type RSP = uvm_sequence_item)
  extends uvm_agent;

  `uvm_component_param_utils(apb_agent #(REQ,RSP))

  typedef uvm_sequencer #(REQ,RSP) apb_sequencer_t;
  typedef apb_driver     #(REQ,RSP) apb_driver_t;

  apb_sequencer_t sequencer;
  apb_driver_t    driver;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = apb_sequencer_t::type_id::create("sequencer", this);
    driver    = apb_driver_t   ::type_id::create("driver",    this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass
