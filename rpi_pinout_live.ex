defmodule RpiPinoutLive do
  use Phoenix.LiveComponent

  @moduledoc File.read!("README.md")
             |> String.split("# RpiPinoutLive")
             |> Enum.fetch!(1)

  @impl true
  def update(assigns, socket) do
    assigns =
      assigns
      |> Map.put_new(:legend, true)
      |> Map.put_new(:target, nil)
      |> build_display_opts()

    {:ok, assign(socket, assigns)}
  end

  defp add_alternates(values) do
    Enum.reduce(values, [], &make_alternate/2)
  end

  defp build_display_opts(assigns) do
    [:disabled_pins, :disabled_gpio, :selected_pins, :selected_gpio]
    |> Enum.reduce(assigns, fn key, assigns ->
      display_opts = Map.get(assigns, :display_opts, %{})
      {values, assigns} = Map.pop(assigns, key, [])
      display_opts = Map.put(display_opts, key, add_alternates(values))
      Map.put(assigns, :display_opts, display_opts)
    end)
  end

  defp build_pin_li(pin, gpio, classes, display_opts, target) do
    disabled? = pin in display_opts.disabled_pins or gpio in display_opts.disabled_gpio
    selected? = pin in display_opts.selected_pins or gpio in display_opts.selected_gpio

    # Disable cursor if pin disabled and remove click
    classes = if disabled?, do: "#{classes} no-cursor", else: classes
    click = if disabled?, do: "", else: ~s(phx-click="rpi_pinout")

    # highlight the pin if selected or disabled
    classes = if selected? or disabled?, do: "#{classes} overlay-pin", else: classes

    # maybe set a target
    target = if target, do: ~s(phx-target="#{target}")

    Phoenix.HTML.raw(
      ~s(<li class="#{classes}" phx-value-pin="#{pin}" phx-value-gpio="#{gpio}" #{click} #{target}>)
    )
  end

  defp make_alternate(val, acc) when is_integer(val), do: [val, to_string(val) | acc]

  defp make_alternate(val, acc) when is_bitstring(val) do
    case Integer.parse(val) do
      {int, ""} -> [val, int | acc]
      _ -> acc
    end
  end

  defp make_alternate(_val, acc), do: acc

  @impl true
  def render(assigns) do
    ~L"""
    <%# Styles adapted from https://github.com/Gadgetoid/Pinout.xyz/blob/master/resources/pinout.css %>
    <%# HTML adapted from generated code at https://github.com/Gadgetoid/Pinout.xyz %>
    <style>

    #gpiocolumn ul, #gpiocolumn li, #gpiocolumn a {
      margin: 0;
      padding: 0;
      text-decoration:none
    }

    #gpiocolumn {
      width:500px;
      font-family: avenir, sans-serif;
      font-weight: 500;
      font-size:16px
    }

    nav#gpio {
      position: relative;
      width: 292px;
      background: #5f8645;
      min-height: 653px;
      margin-right: 208px;
      border-top-right-radius: 46px;
      border-bottom-right-radius:46px;
    }

    nav#gpio:before, nav#gpio:after {
      content: '';
      display: block;
      width: 28px;
      height: 28px;
      background: #fff;
      border-radius: 50%;
      border: 14px solid #f7df84;
      right: 19px;
      top: 19px;
      position:absolute
    }

    nav#gpio:after {
      top: auto;
      bottom:19px
    }

    #gpio ul {
      position: absolute;
      top: 87px;
      list-style:none
    }

    #gpio a {
      display: block;
      position: relative;
      font-size: 1em;
      line-height: 23px;
      height: 22px;
      margin-bottom:2px
    }

    #gpio .phys {
      color: #073642;
      font-size: .8em;
      opacity: .8;
      position: absolute;
      left: 30px;
      text-indent:0
    }

    #gpio .pin {
      display: block;
      border: 1px solid transparent;
      border-radius: 50%;
      width: 16px;
      height: 16px;
      background: #002b36;
      position: absolute;
      right: 2px;
      top:2px
    }

    #gpio .pin:after {
      content: '';
      display: block;
      border-radius: 100%;
      background: #fdf6e3;
      position: absolute;
      left: 5px;
      top: 5px;
      width: 6px;
      height:6px
    }

    #gpio .top {
      left:246px
    }

    #gpio .top li {
      text-indent:56px
    }

    #gpio .top a {
      color: #063541;
      width: 250px;
      border-top-left-radius: 13px;
      border-bottom-left-radius:13px
    }

    #gpio .top .overlay-ground .phys {
      padding-left: 31px;
      left:0
    }

    #gpio .top .pin {
      left: 2px;
      top:2px
    }

    #gpio .top .gnd a {
      color:rgba(6, 53, 65, .5)
    }

    #gpio .bottom {
      left:0
    }

    #gpio .bottom a {
      text-indent: 10px;
      color: #e9e5d2;
      width: 244px;
      border-top-right-radius: 13px;
      border-bottom-right-radius:13px
    }

    #gpio .bottom .overlay-ground .phys {
      padding-right: 32px;
      right:0
    }

    #gpio .bottom .phys {
      text-align: right;
      left: auto;
      right:30px
    }

    #gpio .bottom .gnd a {
      color:rgba(233, 229, 210, .5)
    }

    #gpio .bottom .gnd a:hover {
      color:rgba(6, 53, 65, .5)
    }

    #gpio a:hover, #gpio .active a {
      background: #f5f3ed;
      color:#063541
    }

    #gpio li a small {
      font-size:.7em
    }

    #gpio .overlay-pin a {
      background: #ebe6d3;
      color:#063541
    }

    #gpio .overlay-pin a:hover {
      background: #f5f3ed;
      color:#063541
    }

    #gpio .overlay-pin.gnd a {
      color:rgba(6, 53, 65, .5)
    }

    #gpio .overlay-power .phys {
      color: #fff;
      opacity:1
    }

    #gpio .overlay-power a {
      background: #073642;
      color:#fff
    }

    #gpio .overlay-power a:hover {
      background:#268bd2
    }

    #gpio .overlay-ground .phys {
      background: #073642;
      color: #fff;
      opacity: 1;
      position: absolute;
      top: 0;
      width: 20px;
      height: 22px;
      border-radius: 11px;
      text-indent: 0;
      line-height:22px
    }

    #gpio .overlay-ground a:hover .phys {
      background:#268bd2
    }

    #gpio .overlay-ground span.pin {
      background:#073642
    }

    #gpio ul li.hover-pin a, #gpio .bottom li.hover-pin a {
      color: #fff;
      background:rgba(200, 0, 0, .6)
    }

    #gpio .pin1 a:hover, #gpio .pin1.active a, #gpio .pin1 .pin {
      border-radius:0
    }

    #gpio .pow3v3 .pin {
      background:#b58900
    }

    #gpio .pow5v .pin {
      background:#dc322f
    }

    #gpio .gpio .pin {
      background:#859900
    }

    #gpio .i2c .pin {
      background:#268bd2
    }

    #gpio .spi .pin {
      background:#d33682
    }

    #gpio .uart .pin {
      background:#6c71c4
    }

    #legend h2 {
      margin-top: 20px;
      margin-bottom: 5px;
      font-size:16px
    }

    #legend ul, #legend li {
      list-style: none;
      margin: 0;
      padding:0
    }

    #legend li {
      position: relative;
      margin-bottom: 2px;
      line-height:20px
    }

    #legend li small {
      font-size:10px
    }

    #legend a {
      padding:0 12px 0 30px
    }

    #legend li, #legend a {
      color:#063541
    }

    #legend .pow3v3 .pin {
      background:#b58900
    }

    #legend .pow5v .pin {
      background:#dc322f
    }

    #legend .gpio .pin {
      background:#859900
    }

    #legend .i2c .pin {
      background:#268bd2
    }

    #legend .spi .pin {
      background:#d33682
    }

    #legend .uart .pin {
      background:#6c71c4
    }

    #legend .pin {
      display: block;
      border: 1px solid transparent;
      border-radius: 50%;
      width: 16px;
      height: 16px;
      background: #002b36;
      position: absolute;
      left: 2px;
      top:2px
    }

    #legend .pin:after {
      content: '';
      display: block;
      border-radius: 100%;
      background: #fdf6e3;
      position: absolute;
      left: 5px;
      top: 5px;
      width: 6px;
      height:6px
    }

    #pinbase {
      width: 58px;
      position: absolute;
      left: 216px;
      height: 493px;
      background: #073642;
      top:80px
    }

    .no-cursor {
      cursor: not-allowed;
    }
    </style>

    <div id="gpiocolumn">
      <nav id="gpio">
        <div id="pinbase"></div>
        <ul class="bottom">
          <li class="pin1 pow3v3 no-cursor"><a title=""><span class="default"><span class="phys">1</span> 3v3 Power</span><span class="pin"></span></a></li>
          <%= build_pin_li(3, 2, "pin3 gpio i2c", @display_opts, @target) %><a title="Wiring Pi pin 8"><span class="default"><span class="phys">3</span> BCM 2 <small>(SDA)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(5, 3, "pin5 gpio i2c", @display_opts, @target) %><a title="Wiring Pi pin 9"><span class="default"><span class="phys">5</span> BCM 3 <small(SCL)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(7, 4, "pin7 gpio", @display_opts, @target) %><a title="Wiring Pi pin 7"><span class="default"><span class="phys">7</span> BCM 4 <small>(GPCLK0)</small></span><span class="pin"></span></a></li>
          <li class="pin9 gnd no-cursor"><a title=""><span class="default"><span class="phys">9</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(11, 17, "pin11 gpio", @display_opts, @target) %><a title="Wiring Pi pin 0"><span class="default"><span class="phys">11</span> BCM 17 </span><span class="pin"></span></a></li>
          <%= build_pin_li(13, 27, "pin13 gpio", @display_opts, @target) %><a title="Wiring Pi pin 2"><span class="default"><span class="phys">13</span> BCM 27 </span><span class="pin"></span></a></li>
          <%= build_pin_li(15, 22, "pin15 gpio", @display_opts, @target) %><a title="Wiring Pi pin 3"><span class="default"><span class="phys">15</span> BCM 22 </span><span class="pin"></span></a></li>
          <li class="pin17 pow3v3 no-cursor"><a title=""><span class="default"><span class="phys">17</span> 3v3 Power</span><span class="pin"></span></a></li>
          <%= build_pin_li(19, 10, "pin19 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 12"><span class="default"><span class="phys">19</span> BCM 10 <small>(MOSI)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(21, 9, "pin21 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 13"><span class="default"><span class="phys">21</span> BCM 9 <small>(MISO)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(23, 11, "pin23 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 14"><span class="default"><span class="phys">23</span> BCM 11 <small>(SCLK)</small></span><span class="pin"></span></a></li>
          <li class="pin25 gnd no-cursor"><a title=""><span class="default"><span class="phys">25</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(27, 0, "pin27 gpio i2c", @display_opts, @target) %><a title="Wiring Pi pin 30"><span class="default"><span class="phys">27</span> BCM 0 <small>(ID_SD)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(29, 5, "pin29 gpio", @display_opts, @target) %><a title="Wiring Pi pin 21"><span class="default"><span class="phys">29</span> BCM 5 </span><span class="pin"></span></a></li>
          <%= build_pin_li(31, 6, "pin31 gpio", @display_opts, @target) %><a title="Wiring Pi pin 22"><span class="default"><span class="phys">31</span> BCM 6 </span><span class="pin"></span></a></li>
          <%= build_pin_li(33, 13, "pin33 gpio", @display_opts, @target) %><a title="Wiring Pi pin 23"><span class="default"><span class="phys">33</span> BCM 13 <small>(PWM1)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(35, 19, "pin35 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 24"><span class="default"><span class="phys">35</span> BCM 19 <small>(MISO)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(37, 26, "pin37 gpio", @display_opts, @target) %><a title="Wiring Pi pin 25"><span class="default"><span class="phys">37</span> BCM 26 </span><span class="pin"></span></a></li>
          <li class="pin39 gnd no-cursor"><a title=""><span class="default"><span class="phys">39</span> Ground</span><span class="pin"></span></a></li>
        </ul>
        <ul class="top">
          <li class="pin2 pow5v no-cursor"><a title=""><span class="default"><span class="phys">2</span> 5v Power</span><span class="pin"></span></a></li>
          <li class="pin4 pow5v no-cursor"><a title=""><span class="default"><span class="phys">4</span> 5v Power</span><span class="pin"></span></a></li>
          <li class="pin6 gnd no-cursor"><a title=""><span class="default"><span class="phys">6</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(8, 14, "pin8 gpio uart", @display_opts, @target) %><a title="Wiring Pi pin 15"><span class="default"><span class="phys">8</span> BCM 14 <small>(TXD)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(10, 15, "pin10 gpio uart", @display_opts, @target) %><a title="Wiring Pi pin 16"><span class="default"><span class="phys">10</span> BCM 15 <small>(RXD)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(12, 18, "pin12 gpio", @display_opts, @target) %><a title="Wiring Pi pin 1"><span class="default"><span class="phys">12</span> BCM 18 <small>(PWM0)</small></span><span class="pin"></span></a></li>
          <li class="pin14 gnd no-cursor"><a title=""><span class="default"><span class="phys">14</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(16, 3, "pin16 gpio", @display_opts, @target) %><a title="Wiring Pi pin 4"><span class="default"><span class="phys">16</span> BCM 23 </span><span class="pin"></span></a></li>
          <%= build_pin_li(18, 24, "pin18 gpio", @display_opts, @target) %><a title="Wiring Pi pin 5"><span class="default"><span class="phys">18</span> BCM 24 </span><span class="pin"></span></a></li>
          <li class="pin20 gnd no-cursor"><a title=""><span class="default"><span class="phys">20</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(22, 25, "pin22 gpio", @display_opts, @target) %><a title="Wiring Pi pin 6"><span class="default"><span class="phys">22</span> BCM 25 </span><span class="pin"></span></a></li>
          <%= build_pin_li(24, 8, "pin24 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 10"><span class="default"><span class="phys">24</span> BCM 8 <small>(CE0)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(26, 7, "pin26 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 11"><span class="default"><span class="phys">26</span> BCM 7 <small>(CE1)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(28, 1, "pin28 gpio i2c", @display_opts, @target) %><a title="Wiring Pi pin 31"><span class="default"><span class="phys">28</span> BCM 1 <small>(ID_SC)</small></span><span class="pin"></span></a></li>
          <li class="pin30 gnd no-cursor"><a title=""><span class="default"><span class="phys">30</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(32, 12, "pin32 gpio", @display_opts, @target) %><a title="Wiring Pi pin 26"><span class="default"><span class="phys">32</span> BCM 12 <small>(PWM0)</small></span><span class="pin"></span></a></li>
          <li class="pin34 gnd no-cursor"><a title=""><span class="default"><span class="phys">34</span> Ground</span><span class="pin"></span></a></li>
          <%= build_pin_li(36, 16, "pin36 gpio", @display_opts, @target) %><a title="Wiring Pi pin 27"><span class="default"><span class="phys">36</span> BCM 16 </span><span class="pin"></span></a></li>
          <%= build_pin_li(38, 20, "pin38 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 28"><span class="default"><span class="phys">38</span> BCM 20 <small>(MOSI)</small></span><span class="pin"></span></a></li>
          <%= build_pin_li(40, 21, "pin40 gpio spi", @display_opts, @target) %><a title="Wiring Pi pin 29"><span class="default"><span class="phys">40</span> BCM 21 <small>(SCLK)</small></span><span class="pin"></span></a></li>
        </ul>
      </nav>
      <%= if @legend do %>
        <div id="legend">
          <h2>Legend</h2>
          <ul>
            <li class="gpio">
              <a href="/pinout/wiringpi" title="GPIO (General Purpose IO)">
                <span class="default"></span>
                <span class="pin"></span> GPIO <small>(General Purpose IO)</small>
              </a>
            </li>
            <li class="spi">
              <a href="/pinout/spi" title="SPI (Serial Peripheral Interface)">
                <span class="default"></span>
                <span class="pin"></span> SPI <small>(Serial Peripheral Interface)</small>
              </a>
            </li>
            <li class="i2c">
              <a href="/pinout/i2c" title="I2C (Inter-integrated Circuit)">
                <span class="default"></span>
                <span class="pin"></span> I<sup>2</sup>C <small>(Inter-integrated Circuit)</small>
              </a>
            </li>
            <li class="uart">
              <a href="/pinout/uart" title="UART (Universal Asyncronous Receiver/Transmitter)">
                <span class="default"></span>
                <span class="pin"></span> UART <small>(Universal Asyncronous Receiver/Transmitter)</small>
              </a>
            </li>
            <li class="gnd">
              <a href="/pinout/ground" title="Ground">
                <span class="default"></span>
                <span class="pin"></span> Ground
              </a>
            </li>
            <li class="pow5v">
              <a href="/pinout/pin2_5v_power" title="5v (Power)">
                <span class="default"></span>
                <span class="pin"></span> 5v <small>(Power)</small>
              </a>
            </li>
            <li class="pow3v3">
              <a href="/pinout/pin1_3v3_power" title="3.3v (Power)">
                <span class="default"></span>
                <span class="pin"></span> 3.3v <small>(Power)</small>
              </a>
            </li>
          </ul>
        </div>
      <% end %>
    </div>
    """
  end
end
