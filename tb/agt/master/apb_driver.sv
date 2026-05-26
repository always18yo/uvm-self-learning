//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class apb_driver #(type REQ = uvm_sequence_item,
                   type RSP = uvm_sequence_item)
  extends uvm_driver #(REQ,RSP);

  `uvm_component_param_utils(apb_driver #(REQ,RSP))

  // Virtual interface & config
  virtual clk_rst_if clk_rst_vif;
  virtual apb_if     apb_vif;
  spi_cfg            spi_cfg_h;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------------
  // CONNECT: lấy vif & cfg từ config_db
  //------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (!uvm_config_db#(virtual clk_rst_if)::get(this,"","CLK_RST_VIF",clk_rst_vif))
      `uvm_fatal("CFG","APB_DRV: Cannot get CLK_RST_VIF");

    if (!uvm_config_db#(virtual apb_if)::get(this,"","APB_VIF",apb_vif))
      `uvm_fatal("CFG","APB_DRV: Cannot get APB_VIF");

    if (!uvm_config_db#(spi_cfg)::get(this,"","spi_cfg",spi_cfg_h))
      `uvm_fatal("CFG","APB_DRV: Cannot get spi_cfg");
  endfunction

  //------------------------------------------------------------------
  // APB helper: đưa bus về trạng thái idle
  //------------------------------------------------------------------
  task automatic apb_idle();
    apb_vif.PSEL    <= 1'b0;
    apb_vif.PENABLE <= 1'b0;
    apb_vif.PWRITE  <= 1'b0;
    apb_vif.PADDR   <= '0;
    apb_vif.PWDATA  <= '0;
  endtask


  task automatic apb_write(bit [31:0] addr, bit [31:0] wdata);
    @(posedge clk_rst_vif.clk);
    apb_vif.PADDR   <= addr;
    apb_vif.PWDATA  <= wdata;
    apb_vif.PWRITE  <= 1'b1;
    apb_vif.PSEL    <= 1'b1;
    apb_vif.PENABLE <= 1'b0;

    @(posedge clk_rst_vif.clk);
    apb_vif.PENABLE <= 1'b1;

    do begin
      @(posedge clk_rst_vif.clk);
    end while (!apb_vif.PREADY);

    apb_vif.PSEL    <= 1'b0;
    apb_vif.PENABLE <= 1'b0;
    apb_vif.PWRITE  <= 1'b0;
  endtask

  task automatic apb_read(bit [31:0] addr, output bit [31:0] rdata);
    // SETUP phase
    @(posedge clk_rst_vif.clk);
    apb_vif.PADDR   <= addr;
    apb_vif.PWRITE  <= 1'b0;
    apb_vif.PSEL    <= 1'b1;
    apb_vif.PENABLE <= 1'b0;

    // ENABLE phase
    @(posedge clk_rst_vif.clk);
    apb_vif.PENABLE <= 1'b1;

    // Chờ PREADY, sau đó chốt PRDATA
    do begin
      @(posedge clk_rst_vif.clk);
    end while (!apb_vif.PREADY);

    rdata = apb_vif.PRDATA;

    // Kết thúc
    apb_vif.PSEL    <= 1'b0;
    apb_vif.PENABLE <= 1'b0;
  endtask


  task run_phase(uvm_phase phase);
    REQ req;
    RSP rsp;
    bit [31:0] rdata;

    // Đưa bus về idle lúc đầu
    apb_idle();

    forever begin
      @(posedge clk_rst_vif.clk);
      seq_item_port.get_next_item(req);

      `uvm_info("APB_DRV",
                $sformatf("Got item: addr=0x%08h wdata=0x%08h wr_rd=%0b do_reset=%0b do_wait=%0b",
                          req.addr, req.wdata, req.wr_rd, req.do_reset, req.do_wait),
                UVM_MEDIUM)

      if (req.do_reset) begin
        clk_rst_vif.do_reset(5);
        apb_idle();
      end
      else if (req.do_wait) begin
        clk_rst_vif.do_wait(5);
      end
      else if (req.wr_rd) begin
        // WRITE
        apb_write(req.addr, req.wdata);
      end
      else begin
        apb_read(req.addr, rdata);
      end

      // tạo response mirror lại request
      rsp = RSP::type_id::create("rsp", this);
      if (rsp != null)
        rsp.copy(req);

      seq_item_port.item_done(rsp);
    end
  endtask

endclass
  
