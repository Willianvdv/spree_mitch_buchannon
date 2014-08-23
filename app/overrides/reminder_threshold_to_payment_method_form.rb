Deface::Override.new(:virtual_path => "spree/admin/payment_methods/_form",
                    :name => "reminder_threshold_to_payment_method_form",
                    :insert_bottom => "[data-hook='description']",
                    :text => '
                      <div class="field">
                        <%= label_tag nil, Spree.t(:reminder_treshold) %>
                        <%= text_field :payment_method, :reminder_threshold, :class => "fullwidth" %>
                      </div>
                    ')
