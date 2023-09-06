create index concurrently
idx_search_requests on ris.requests
using GIST (search);

CREATE INDEX index_ris_patients_on_requests ON ris.requests USING btree (seqno,PatNumber);


--Sample 
SELECT
	*
FROM
	ris.get_reportroomrowsbyfil (
		'5/9/2017'
		,'3/12/2020'
		,NULL
		,'{"head & neck","chest & cardiovascular","breast","body","musculoskeletal","spine"}'
    ,NULL
		,'{"free","private wing","normal"}' 
    ,'{"ready for reading", "reading","additional image","show patient","consult requested","pending approval"}'
		,'{"14"}'
	)
    