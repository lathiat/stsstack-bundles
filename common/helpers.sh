declare -A parameters=()
declare -a overlays=()

_usage () {
cat << EOF
USAGE: `basename $0` INTERNAL_OPTS OPTIONS [OVERLAYS]

OPTIONS:
     --create-model
        Create Juju model using --name. Switches to model if it already
        exists. If this is not provided then the current Juju model is used.
     -h, --help
        Display this help message.
     --list
        List existing bundles.
     --list-overlays
        List supported overlays.
     --list-opts
        List extra options supported by bundle.
     -n, --name n
        Name for bundle. If this is not provided then the default bundle
        location is used.
     -p, --pocket p
        Archive pocket to install packages from e.g. "proposed".
     -r, --release r
        Openstack release. This allows UCA to be used otherwise base archive
        of release is used.
     --replay
        Replay last command for bundle --name (or default bundle if no name
        provided).
     --run
        Automatically execute the generated deployment command.
     -s, --series s
        Ubuntu series.
    --use-stable-charms
        By default the development (cs:~openstack-charmers-next) version of
        the charms are used where available. Use this flag if you want to
        use the stable (released) charms i.e. cs:<charm>.

OVERLAYS:
     You can optionally add one or more feature overlay. These are
     specified as --<overlayname> using the name of an overlay as found in
     the output of running ./generate-bundle.sh --list-overlays.

     Note that overlays listed with a asterisk at the end of the name
     support having a number of units specified using a colon e.g.

     ./generate-bundle.sh --myoverlay:6

     will give you six units of myoverlay. This is useful for overlays
     that provide HA or scale-out services. See --list-overlays for
     available overlays.

INTERNAL_OPTS (don't use these):
     --internal-bundle-params <path>
        (internal only) Bundle parameters passed by sub-generator
     --internal-overlay <path>
        (internal only) Overlay to be added to deployment. Can be
        specified multiple times.
     --internal-generator-path <path>
        (internal only) Bundle generator path.
     --internal-template <path>
        (internal only) Bundle generator base template.
     --internal-version-info <path>
        (internal only) 
EOF
list_opts
}

get_units()
{
    units=`echo $1| sed -r 's/.+:([[:digit:]])/\1/;t;d'`
    [ -n "$units" ] || units=$3
    parameters[$2]=$units
}

get_param()
{
    read -p "$2" val
    parameters[$1]="$val"
}


generate()
{
    # path to file containing series/release info
    (($#)) && opts+=( "--internal-version-info $1" )

    for overlay in ${overlays[@]:-}; do
        opts+=( "--internal-overlay $overlay" )
    done

    ftmp=
    if ((${#parameters[@]})); then
        ftmp=`mktemp`
        echo -n "sed -i " > $ftmp
        for p in ${!parameters[@]}; do
            echo -n "-e 's/$p/${parameters[$p]}/g' " >> $ftmp
        done
        opts+=( "--internal-bundle-params $ftmp" )
    fi

    `dirname $0`/common/generate-bundle.sh ${opts[@]}

    [ -n "$ftmp" ] && rm $ftmp
}

list_overlays ()
{
    echo "Supported overlays:"
    sed -r 's/.+\s+(--[[:alnum:]\-]+\*?).+/\1/g;t;d' `basename $0`| \
        egrep -v "\--list-overlays|--num-compute|--num-ceph-mons|--neutron-fw-driver"
}

list_opts ()
{
    echo -e "\nBUNDLE OPTS:"
    sed -r 's/.+\s+(--[[:alnum:]\-]+).+#type:(.+)/      \1 \2/g;t;d' `basename $0`
}
