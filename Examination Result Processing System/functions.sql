-- Grade Calculation Function
CREATE OR REPLACE FUNCTION calculate_grade (
    p_percentage IN NUMBER
) RETURN VARCHAR2
IS
    v_grade VARCHAR2(2);
BEGIN
    IF p_percentage >= 90 THEN
        v_grade := 'A';
    ELSIF p_percentage >= 75 THEN
        v_grade := 'B';
    ELSIF p_percentage >= 60 THEN
        v_grade := 'C';
    ELSIF p_percentage >= 40 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'F';
    END IF;

    RETURN v_grade;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N/A';
END;
/
