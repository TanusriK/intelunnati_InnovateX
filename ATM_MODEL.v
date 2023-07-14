module ATM_MODEL (
    input wire clk,
    input wire reset,
    input wire card_insert,
    input wire pin_enter,
    input wire txn_select,
    input wire txn_confirm,
    output wire txn_complete,
    output wire txn_failed
);

    // Define states
    parameter IDLE = 2'b00;
    parameter CARD_INSERTED = 2'b01;
    parameter PIN_ENTERED = 2'b10;
    parameter TRANSACTION_SELECTED = 2'b11;

    // Registers for the FSM
    reg [1:0] state_reg;
    reg [1:0] state_next;

    // Output signals
    reg txn_complete_reg;
    reg txn_failed_reg;

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            txn_complete_reg <= 1'b0;
            txn_failed_reg <= 1'b0;
        end else begin
            state_reg <= state_next;
            txn_complete_reg <= 1'b0;
            txn_failed_reg <= 1'b0;
        end
    end

    always @(state_reg or card_insert or pin_enter or txn_select or txn_confirm) begin
        state_next = state_reg;

        case (state_reg)
            IDLE: begin
                if (card_insert)
                    state_next = CARD_INSERTED;
            end
            CARD_INSERTED: begin
                if (pin_enter)
                    state_next = PIN_ENTERED;
                else if (!card_insert)
                    state_next = IDLE;
            end
            PIN_ENTERED: begin
                if (txn_select)
                    state_next = TRANSACTION_SELECTED;
                else if (!pin_enter)
                    state_next = IDLE;
            end
            TRANSACTION_SELECTED: begin
                if (txn_confirm)
                    state_next = IDLE;
                else if (!txn_select)
                    state_next = IDLE;
            end
        endcase
    end

    // Assign outputs
    assign txn_complete = txn_complete_reg;
    assign txn_failed = txn_failed_reg;

endmodule