-- tunas360 configuration file. for those cases where you must change tunas360 functionality

/*************************** ok to modify (if really needed) ****************************/

-- Whatever limit if reached first (either time or number of rows) interrupts the execution

-- rely on Oracle Diagnostic Pack, disabled by default
DEF tunas360_diag_license = 'N';

-- max time to run for (in minutes)
DEF tunas360_max_time = '10';

/**************************** not recommended to modify *********************************/

-- excluding report types reduce usability while providing marginal performance gain
DEF tunas360_conf_incl_html   = 'Y';
DEF tunas360_conf_incl_text   = 'N';
DEF tunas360_conf_incl_csv    = 'N';
DEF tunas360_conf_incl_xml    = 'N';
DEF tunas360_conf_incl_line   = 'Y';
DEF tunas360_conf_incl_pie    = 'Y';
DEF tunas360_conf_incl_bar    = 'Y';
DEF tunas360_conf_incl_tree   = 'Y';
DEF tunas360_conf_incl_bubble = 'Y';

-- include/exclude SQL Monitor reports
DEF tunas360_conf_incl_sqlmon = 'Y';

-- include/exclude BACKGROUND processes (excluded by default)
DEF tunas360_conf_incl_background = 'N';

-- max number of rows to collect
DEF tunas360_max_rows = '1000000';

-- sleep time between samples (in seconds)
DEF tunas360_sleep_time = '0.1';

-- number of top sessions to focus on
DEF tunas360_num_top_sess = '5';

-- number of top SQL to capture plan for 
DEF tunas360_num_top_sqls_plan = '5';

-- How many days to use to determine baseline, need Diag Pack license 
DEF tunas360_baseline_history = '7';

-- number of segments to report stats for 
DEF tunas360_num_top_segments = '50';

/**************************** not recommended to modify *********************************/

DEF tunas360_conf_eDB360_page = '<a href="http://www.enkitec.com/products/edb360" target="_blank">';
DEF tunas360_conf_SQLd360_page = '<a href="http://www.enkitec.com/products/sqld360" target="_blank">';
DEF tunas360_conf_Snapper_page = '<a href="http://blog.tanelpoder.com/files/scripts/snapper.sql" target="_blank">';

--DEF tunas360_conf_tool_page = '<a href="http://mauro-pagano.com/2015/02/16/tunas360-sql-diagnostics-collection-made-faster/" target="_blank">';
DEF tunas360_conf_tool_page = '<a href="http://mauro-pagano.com/" target="_blank">';
--DEF tunas360_conf_all_pages_icon = '<a href="http://www.enkitec.com/products/tunas360" target="_blank"><img src="TUNAs360_img.jpg" alt="TUNAs360" height="63" width="61"></a>';
--DEF tunas360_conf_all_pages_icon = '<a href="http://mauro-pagano.com/2015/02/16/tunas360-sql-diagnostics-collection-made-faster/" target="_blank"><img src="TUNAs360_img.jpg" alt="TUNAs360" height="63" width="61"></a>';
DEF tunas360_conf_all_pages_icon = '<a href="http://mauro-pagano.com/" target="_blank"><img src="TUNAs360_img.jpg" alt="TUNAs360" height="63" width="61"></a>';
--DEF tunas360_conf_all_pages_logo = '<img src="TUNAs360_all_pages_logo.jpg" alt="Enkitec now part of Accenture" width="117" height="29">';
DEF tunas360_conf_all_pages_logo = '';
DEF tunas360_conf_google_charts = '<script type="text/javascript" src="https://www.google.com/jsapi"></script>';


/**************************** enter your modifications here *****************************/

--DEF tunas360_conf_incl_text = 'N';
--DEF tunas360_conf_incl_csv = 'N';

