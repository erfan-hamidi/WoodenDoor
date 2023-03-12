-- 1

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
		 

-- 2
CREATE OR REPLACE FUNCTION remove_user_if_dislikes()
RETURNS TRIGGER AS $$
DECLARE
	total_reacts INTEGER;
	dislikes INTEGER;
	dislike_percentage NUMERIC;
BEGIN
		SELECT COUNT(*) INTO total_reacts FROM React WHERE email = NEW.email;
		SELECT COUNT(*) INTO dislikes FROM React WHERE email = NEW.email AND reaction = 'D';
		dislike_percentage = (dislikes::NUMERIC / total_reacts::NUMERIC) * 100;

		IF total_reacts > 100 AND dislike_percentage > 95 THEN
			DELETE FROM User_field WHERE email = NEW.email;
		END IF;

		RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_user_reacts
AFTER INSERT ON React
FOR EACH ROW
EXECUTE FUNCTION remove_user_if_dislikes();
