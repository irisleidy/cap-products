namespace com.training;

using {
    cuid,
    Country
} from '@sap/cds/common';

entity Course : cuid {
    Student : Association to many StudentCourse
                  on Student.Course = $self;
}

entity Student : cuid {
    Course : Association to many StudentCourse
                 on Course.Student = $self;
}

entity StudentCourse : cuid {
    Student : Association to one Student;
    Course  : Association to one Course;
}

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed     : Boolean;
        Approved    : Boolean;
        Country     : Country;
        Status      : String(1);
}