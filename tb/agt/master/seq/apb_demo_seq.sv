//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class apb_demo_seq #(type REQ = uvm_sequence_item,
                     type RSP = uvm_sequence_item)
  extends uvm_sequence #(REQ,RSP);

  `uvm_object_param_utils(apb_demo_seq #(REQ,RSP))

  spi_cfg spi_cfg_h;

  function new(string name = "apb_demo_seq");
    super.new(name);
  endfunction

  task body();
    REQ req; RSP rsp;
    bit [31:0] ctrl_word;
    bit [31:0] tx_data[4];

    if (!uvm_config_db#(spi_cfg)::get(null,"*","spi_cfg",spi_cfg_h))
      `uvm_fatal("CFG","apb_demo_seq: cannot get spi_cfg");

    // random + mask
    if (!spi_cfg_h.randomize())
      `uvm_error("CFG","randomize spi_cfg failed");
    spi_cfg_h.set_mask();

    // reset
    req = REQ::type_id::create("reset", this);
    start_item(req);
      req.addr     = '0;
      req.wdata    = '0;
      req.wr_rd    = 0;
      req.do_reset = 1;
      req.do_wait  = 0;
    finish_item(req);
    get_response(rsp);

    // wait
    req = REQ::type_id::create("wait", this);
    start_item(req);
      req.addr     = '0;
      req.wdata    = '0;
      req.wr_rd    = 0;
      req.do_reset = 0;
      req.do_wait  = 1;
    finish_item(req);
    get_response(rsp);

    // 4 TX writes
    tx_data[0] = 32'hAAAA_AAAA;
    tx_data[1] = 32'h5555_5555;
    tx_data[2] = 32'hFFFF_0000;
    tx_data[3] = 32'h1234_5678;

    foreach (tx_data[i]) begin
      req = REQ::type_id::create($sformatf("tx%0d",i), this);
      start_item(req);
        req.addr     = i*4;   // 0,4,8,12
        req.wdata    = tx_data[i];
        req.wr_rd    = 1;
        req.do_reset = 0;
        req.do_wait  = 0;
      finish_item(req);
      get_response(rsp);
    end

    // control write at addr 16
    ctrl_word = '0;
    ctrl_word[13]   = spi_cfg_h.ass;
    ctrl_word[12]   = spi_cfg_h.ie;
    ctrl_word[11]   = spi_cfg_h.lsb;
    ctrl_word[10]   = spi_cfg_h.txneg;
    ctrl_word[9]    = spi_cfg_h.rxneg;
    ctrl_word[8]    = 1'b1;                // GO_BSY
    ctrl_word[6:0]  = spi_cfg_h.char_len;

    req = REQ::type_id::create("ctrl", this);
    start_item(req);
      req.addr     = 32'd16;
      req.wdata    = ctrl_word;
      req.wr_rd    = 1;
      req.do_reset = 0;
      req.do_wait  = 0;
    finish_item(req);
    get_response(rsp);
  endtask

endclass

