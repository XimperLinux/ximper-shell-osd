[CCode (cheader_filename = "ddcutil_c_api.h")]
namespace Ddcutil {

    [CCode (cname = "DDCA_Syslog_Level", cprefix = "DDCA_SYSLOG_")]
    public enum SyslogLevel {
        [CCode (cname = "DDCA_SYSLOG_NOT_SET")]
        NOT_SET,
        [CCode (cname = "DDCA_SYSLOG_NEVER")]
        NEVER
    }

    [CCode (cname = "DDCA_Init_Options", cprefix = "DDCA_INIT_OPTIONS_")]
    [Flags]
    public enum InitOptions {
        [CCode (cname = "DDCA_INIT_OPTIONS_NONE")]
        NONE,
        [CCode (cname = "DDCA_INIT_OPTIONS_DISABLE_CONFIG_FILE")]
        DISABLE_CONFIG_FILE
    }

    [CCode (cname = "DDCA_Non_Table_Vcp_Value", has_type_id = false)]
    public struct NonTableVcpValue {
        public uint8 mh;
        public uint8 ml;
        public uint8 sh;
        public uint8 sl;
    }

    // All fields must be present to match C struct layout
    [CCode (cname = "DDCA_Display_Info", has_type_id = false, destroy_function = "")]
    public struct DisplayInfo {
        public char marker[4];
        public int dispno;
        [CCode (cname = "path")]
        public uint8 _path[8];
        public int usb_bus;
        public int usb_device;
        public char mfg_id[4];
        public char model_name[14];
        public char sn[14];
        public uint16 product_code;
        public uint8 edid_bytes[128];
        [CCode (cname = "vcp_version")]
        public uint8 _vcp_version[2];
        [CCode (cname = "dref")]
        public void* dref;
    }

    [CCode (cname = "DDCA_Display_Info_List", has_type_id = false,
            free_function = "ddca_free_display_info_list")]
    [Compact]
    public class DisplayInfoList {
        public int ct;
        [CCode (cname = "info", array_length_cname = "ct")]
        public DisplayInfo info[0];
    }

    [CCode (cname = "ddca_init2")]
    public static int init2 (
        string? libopts,
        SyslogLevel syslog_level,
        InitOptions opts,
        [CCode (array_length = false)]
        out string[]? infomsg);

    [CCode (cname = "ddca_get_display_info_list2")]
    public static int get_display_info_list2 (
        bool include_invalid,
        out DisplayInfoList? dlist);

    [CCode (cname = "ddca_open_display2")]
    public static int open_display2 (
        void* dref,
        bool wait,
        out void* dh);

    [CCode (cname = "ddca_close_display")]
    public static int close_display (void* dh);

    [CCode (cname = "ddca_get_non_table_vcp_value")]
    public static int get_non_table_vcp_value (
        void* dh,
        uint8 feature_code,
        out NonTableVcpValue valrec);

    [CCode (cname = "ddca_set_non_table_vcp_value")]
    public static int set_non_table_vcp_value (
        void* dh,
        uint8 feature_code,
        uint8 hi_byte,
        uint8 lo_byte);
}
