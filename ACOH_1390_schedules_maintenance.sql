/**
 *
 * $URL: https://subversion.quartalfs.com/svn/COMM.PRODUCT.DB/branches/DB9.2/Database/base_data/ACOH/ACOH_053_SCHEDULE.sql $:  Subversion Url<br>
 * $Rev:: 78683                                                 $:  Revision of last commit<br>
 * $Author:: arribas                                            $:  Author of last commit<br>
 * $Date:: 2018-02-08 13:15:03 +0100 (Thu, 08 Feb 2018)         $:  Date of last commit<p>
 * © Quartal Financial Solutions AG
 * @headcom
 */

--       ,PAR_SCH_STATUS                  => public enum ScheduleStatus{ Enabled = 1, Disabled = 2, Processing = 3, Error = 4 } 

--       ,PAR_SCH_RECURRENCETYPE          => public enum ScheduleRecurrenceType{ ByMinute = 1, Hourly = 2, Daily = 3, Monthly = 4 } 
--       ,PAR_SCH_INTERVAL                => 1, 2, 3, 4 
--        Note that [RECURRENCETYPE=1 AND INTERVAL=4] means every 4 minutes, RECURRENCETYPE=2] AND INTERVAL=3 means every 3 hours, [RECURRENCETYPE=3 AND INTERVAL=2] means every 2 days, [RECURRENCETYPE=4 AND INTERVAL=1] means every 1 month, etc.     

BEGIN
    
	    INSTALL.MAINTAIN_SCHEDULE
    (
        PAR_SCH_KEYNAME                 => 'ACOH_GENERATE_CALC_TASKS_60101_EndOfPeriod_ADD2'
       ,PAR_SCH_DESCRIPTION             => 'Trailer Fee FINAL, Cooperation Partner, Current Period, EndOfPeriod'
       ,PAR_SERVERTASK_ID               => INSTALL.GET_ST_ID_BY_ST_KEYNAME('ACOH_GENERATE_CALC_TASKS_60101_EndOfPeriod_ADD2')
       ,PAR_SCH_STATUS                  => 1 -- enabled
       ,PAR_SCH_START                   => TO_DATE((TO_CHAR(TRUNC(SYSDATE),'MM/DD/YYYY')||' '||'00:01:00'), 'MM/DD/YYYY HH24:MI:SS')
       ,PAR_SCH_END                     => TO_DATE('9999-12-31', 'YYYY-MM-DD') 
       ,PAR_SCH_RECURRENCETYPE          => 3 -- Daily
       ,PAR_SCH_INTERVAL                => 1
       ,PAR_SCH_MONTHFILTER             => 4095
       ,PAR_SCH_DAYFILTER               => 127
       ,PAR_SCH_NEXTRUN                 => NULL
       ,PAR_SCH_LASTRUN                 => NULL
       ,PAR_CLIENT_ID                   => 1
    );


    COMMIT;

	
END;
/ 


