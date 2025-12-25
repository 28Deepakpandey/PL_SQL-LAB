-- Create Results View
CREATE OR REPLACE VIEW view_results AS
SELECT 
    r.rank,
    s.student_name,
    r.total_marks,
    r.percentage,
    r.grade,
    r.status
FROM results r
JOIN students s ON r.student_id = s.student_id
ORDER BY r.rank;
