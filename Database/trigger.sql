CREATE OR REPLACE FUNCTION remove_old_job_ad() RETURNS TRIGGER AS $$
BEGIN
	  DELETE FROM Job_ad WHERE jdate < NOW() - INTERVAL '1 year';
		  RETURN NULL;
		END;
		$$ LANGUAGE plpgsql;

		CREATE TRIGGER remove_old_job_ad_trigger
		AFTER INSERT ON Job_ad
		FOR EACH ROW
			EXECUTE FUNCTION remove_old_job_ad();
