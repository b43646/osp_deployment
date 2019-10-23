## Define IPA Node
CLASSROOM_SERVER=10.149.23.10
PASSWORD_FOR_VMS='r3dh4t1!'
OFFICIAL_IMAGE=rhel7-guest-official.qcow2 

curl -o /tmp/open.repo http://classroom/open13.repo
# Define the /etc/hosts file
cat > /tmp/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

${CLASSROOM_SERVER}  classroom
EOF

virsh net-update provisioning add ip-dhcp-host "<host mac='52:54:00:01:20:21' name='ipa' ip='172.16.0.252'/>" --live --config

cd /var/lib/libvirt/images/
node=ipa
qemu-img create -f qcow2 $node.qcow2 60G
virt-resize --expand /dev/sda1 ${OFFICIAL_IMAGE} $node.qcow2

virt-customize -a $node.qcow2 \
  --hostname $node.example.com \
  --root-password password:${PASSWORD_FOR_VMS} \
  --uninstall cloud-init \
  --copy-in /tmp/hosts:/etc/ \
  --copy-in /tmp/open.repo:/etc/yum.repos.d/ \
  --selinux-relabel

virt-install --ram 2048 --vcpus 1 --os-variant rhel7 --cpu host,+vmx \
--disk path=/var/lib/libvirt/images/$node.qcow2,device=disk,bus=virtio,format=qcow2 \
--noautoconsole --vnc \
--network network=provisioning,mac=52:54:00:01:20:21 \
--name $node --dry-run --print-xml \
> /root/host-ipa.xml

## Create IPA VM
virsh define /root/host-$node.xml

## Start IPA VM
virsh start $node
