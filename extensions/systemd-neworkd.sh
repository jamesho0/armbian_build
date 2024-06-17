#
# Extension for systemd-networkd + systemd-timesyncd
#
function add_host_dependencies__install_network_manager() {
        display_alert "Adding Netplan to systemd-networkd" "systemd-timesyncd" "info"
        add_packages_to_rootfs iproute2 systemd-timesyncd netplan.io
}

function pre_install_kernel_debs__configure_systemd_networkd()
{
	display_alert "${EXTENSION}: enabling systemd-networkd" "" "info"

	# remove default interfaces file if present
	rm -f "${SDCARD}"/etc/network/interfaces

	# enable networkd
	chroot_sdcard systemctl enable systemd-networkd.service || display_alert "Failed to enable systemd-networkd.service" "" "wrn"

	# enable resolved too
	chroot_sdcard systemctl enable systemd-resolved.service || display_alert "Failed to enable systemd-resolved.service" "" "wrn"

	# Mask `NetworkManager.service` to avoid conflict just to make sure
	chroot_sdcard systemctl mask NetworkManager.service

	# Enable timesyncd
	display_alert "${EXTENSION}: enabling systemd-timesyncd" "" "info"
	chroot_sdcard systemctl enable systemd-timesyncd.service

        # Let NetworkManager manage all devices on this system by default
	cat <<- EOF > "${SDCARD}"/etc/netplan/armbian-default.yaml
	# This installation supports NetworkManager renderer only. You need to install additional packages in case you want something else
	network:
	  version: 2
	  renderer: networkd
	  ethernets:
	   eth0:
	    dhcp4: true
	    dhcp6: true
	EOF
}
