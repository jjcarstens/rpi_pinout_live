# RpiPinoutLive

Phoenix LiveView component to render Raspberry Pi pinout from https://pinout.xyz

This is a derivative of https://pinout.xyz by [Pinout.xyz](https://github.com/gadgetoid/Pinout.xyz),
used under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

Each pin is a clickable element that will send a `rpi_pinout` event with
the correlating pin and GPIO number values:

```elixir
def handle_event("rpi_pinout", %{"gpio" => gpio, "pin" => pin}, socket) do
  # Handle GPIO things here
  # i.e. Turn on/off pin, Set configuration, 
end
```

Options:
* `legend` - boolean for showing the pins color legend. Defaults to `true`
* `target` - optional target to send click events to
* `selected_pins` - list of pins that should be highlighted as selected
* `selected_gpio` - list of gpio that should be highlighted as selected
* `disabled_pins` - list of pins that should not be clickable (also highlights)
* `disabled_gpio` - list of gpio that should not be clickable (also highlights)
