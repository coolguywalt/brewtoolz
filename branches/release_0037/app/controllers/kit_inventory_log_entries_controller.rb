class KitInventoryLogEntriesController < ApplicationController

  hobo_model_controller

  auto_actions :all

    # Undo the previous log entry and restore the logged amount to the inventory
  def undo
    @entry = KitInventoryLogEntry.find(params[:id])
    @parent = @entry.kit_inventory

    @parent.amount = @parent.amount.to_f + @entry.amount.to_f
    @entry.destroy
    @parent.save

    redirect_to @parent
  end

  def update
    hobo_update do
      redirect_to this.kit_inventory if valid?
    end
  end

  def create
    hobo_create do

      if valid?
        this.kit_inventory.amount = this.kit_inventory.amount.to_f - this.amount.to_f
        this.kit_inventory.save
      else
        # Need this horrible manual hack because hobo does not know how to handle the subform objects errors
        flash[:error] = this.errors.full_messages
      end

     redirect_to this.kit_inventory

    end
  end


end
