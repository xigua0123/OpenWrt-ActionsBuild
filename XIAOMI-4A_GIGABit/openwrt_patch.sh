#!/bin/bash
#patch
cat >> ./target/linux/ramips/dts/mt7621_xiaomi_mi-router-4a-gagibit.dtsi << EOF
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT

#include "mt7621.dtsi"

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>

/ {
	aliases {
		led-boot = &led_status_yellow;
		led-failsafe = &led_status_yellow;
		led-running = &led_status_blue;
		led-upgrade = &led_status_yellow;
		label-mac-device = &wan;
	};

	chosen {
		bootargs = "console=ttyS0,115200n8";
	};

	leds {
		compatible = "gpio-leds";

		led_status_blue: status_blue {
			label = "blue:status";
			gpios = <&gpio 8 GPIO_ACTIVE_LOW>;
		};

		led_status_yellow: status_yellow {
			label = "yellow:status";
			gpios = <&gpio 10 GPIO_ACTIVE_LOW>;
		};
	};

	keys {
		compatible = "gpio-keys";

		reset {
			label = "reset";
			gpios = <&gpio 18 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};
	};
};

&spi0 {
	status = "okay";

	flash@0 {
		compatible = "jedec,spi-nor";
		reg = <0>;
		spi-max-frequency = <10000000>;

		partitions {
			compatible = "fixed-partitions";
			#address-cells = <1>;
			#size-cells = <1>;

			partition@0 {
				label = "u-boot";
				reg = <0x0 0x30000>;
				read-only;
			};

			partition@30000 {
				label = "u-boot-env";
				reg = <0x30000 0x10000>;
				read-only;
			};

			factory: partition@40000 {
				label = "factory";
				reg = <0x40000 0x10000>;
				read-only;
			};

			partition@50000 {
				compatible = "denx,uimage";
				label = "firmware";
				reg = <0x50000 0xfb0000>;
			};
		};
	};
};

&pcie {
	status = "okay";
};

&pcie0 {
	wifi@0,0 {
		compatible = "pci14c3,7662";
		reg = <0x0000 0 0 0 0>;
		mediatek,mtd-eeprom = <&factory 0x8000>;
		ieee80211-freq-limit = <5000000 6000000>;
	};
};

&pcie1 {
	wifi@0,0 {
		compatible = "pci14c3,7603";
		reg = <0x0000 0 0 0 0>;
		mediatek,mtd-eeprom = <&factory 0x0000>;
		ieee80211-freq-limit = <2400000 2500000>;
	};
};

&gmac0 {
	mtd-mac-address = <&factory 0xe000>;
};

&switch0 {
	ports {
		port@2 {
			status = "okay";
			label = "lan2";
		};

		port@3 {
			status = "okay";
			label = "lan1";
		};

		wan: port@4 {
			status = "okay";
			label = "wan";
			mtd-mac-address = <&factory 0xe006>;
		};
	};
};

&state_default {
	gpio {
		groups = "jtag", "uart2", "uart3", "wdt";
		function = "gpio";
	};
};
EOF
sed -i 's/#include "mt7621_xiaomi_mi-router-4a-3g-v2.dtsi"/#include "mt7621_xiaomi_mi-router-4a-gagibit.dtsi"/g' ./target/linux/ramips/dts/mt7621_xiaomi_mi-router-4a-gigabit.dts
sed -i '/define Device\/xiaomi_mi-router-4a-gigabit/{:a;n;s/IMAGE_SIZE := 14848k/IMAGE_SIZE := 16064k/g;/TARGET_DEVICES += xiaomi_mi-router-4a-gigabit/!ba}' ./target/linux/ramips/image/mt7621.mk
#openwrt仓库拉取luci
cat >> feeds.conf.default << EOF
src-git luci https://github.com/openwrt/luci.git
EOF

