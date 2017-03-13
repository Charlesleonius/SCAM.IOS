//
//  InitialProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/4/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import DropDown

class InitialProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var minorsTable: UITableView!
    @IBOutlet weak var classesTable: UITableView!
    
    @IBOutlet weak var majorTextField: SCMTextField!
    @IBOutlet weak var doubleMajorField: SCMTextField!
    
    private var classFields = 4
    private var minorFields = 2
    private var majors = [
        "BS, Aerospace Engineering",
        "MS, Aerospace Engineering",
        "BA, African-American Studies",
        "BA, Humanities (American Studies)",
        "BA, Anthropology",
        "BA, Behavioral Science",
        "BA, Organizational Studies",
        "MA, Applied Anthropology",
        "BA, Art (Art History and Visual Culture)",
        "BA, Art (Studio Practice)",
        "BA, Art (Studio Practice- Preparation for Teaching)",
        "BFA, Art (Digital Media Art)",
        "BFA, Art (Photography)",
        "BFA, Art (Pictorial Art)",
        "BFA, Art (Spatial Art)",
        "MA, Art, Art History and Visual Culture",
        "MFA, Art, Digital Media Art",
        "MFA, Art, Photography",
        "MFA, Art, Pictorial Art",
        "MFA, Art, Spatial Art",
        "BA, Humanities (Asian Studies)",
        "BS, Aviation",
        "BA, Behavioral Science",
        "BA, Biological Science",
        "BS, Biological Science (Ecology and Evolution)",
        "BS, Biological Science (Marine Biology)",
        "BS, Biological Science (Microbiology)",
        "BS, Biological Science (Molecular Biology)",
        "BS, Biological Science (Systems Physiology)",
        "MBT, Master Biotechnology",
        "MA, Biological Sciences",
        "MS, Biological Sciences (Ecology and Evolution)",
        "MS, Biological Sciences (Physiology)",
        "MS, Biological Sciences (Molecular Biology and Microbiology)",
        "BS, Biomedical Engineering",
        "BS, Chemical Engineering",
        "BS, Materials Engineering",
        "MS, Biomedical Engineering",
        "MS, Biomedical Engineering (Biomedical Devices)",
        "MS, Chemical Engineering",
        "MS, Materials Engineering",
        "BS, Business Administration (Accounting)",
        "BS, Business Administration (Accounting Information Systems)",
        "BS, Business Administration (Business Analytics)",
        "BS, Business Administration (Corporate Accounting and Finance)",
        "BS, Business Administration (Entrepreneurship)",
        "BS, Business Administration (Finance)",
        "BS, Business Administration (General Business)",
        "BS, Business Administration (Global Operations Management)",
        "BS, Business Administration (Human Resource Management)",
        "BS, Business Administration (International Business)",
        "BS, Business Administration (Management)",
        "BS, Business Administration (Management Information Systems)",
        "BS, Business Administration (Marketing)",
        "MBA, Early Career MBA",
        "MBA, MBA for Professionals",
        "MS, Accountancy",
        "MS, Taxation (Special Session Program)",
        "MS, Transportation Management (Special Session Program)",
        "BA, Chemistry",
        "BS, Chemistry",
        "BS, Chemistry (Biochemistry)",
        "MA, Chemistry",
        "MS, Chemistry",
        "BA, Child and Adolescent Development",
        "BA, Child and Adolescent Development, Preparation for Teaching",
        "MA, Child and Adolescent Development",
        "BS, Civil Engineering",
        "MS, Civil Engineering",
        "BA, Communication Studies",
        "BA, Communication Studies, Preparation for Teaching",
        "MA, Communication Studies",
        "BS, Computer Engineering",
        "BS, Software Engineering",
        "MS, Computer Engineering",
        "MS, Software Engineering",
        "MS, Software Engineering (Cybersecurity)",
        "BS, Computer Science",
        "MS, Computer Science",
        "BA, Creative Arts",
        "BA, Creative Arts, Preparation for Teaching",
        "BA, Art (Design Studies)",
        "BS, Industrial Design",
        "BFA, Art, Animation/Illustration",
        "BFA, Graphic Design",
        "BFA, Interior Design",
        "BA, Economics",
        "BS, Economics",
        "MA, Economics",
        "MA, Economics (Applied Economics)",
        "BA, Communicative Disorders and Sciences",
        "MA, Education (Speech Pathology)",
        "MA, Education (Counseling and Student Personnel)",
        "EdD, Educational Leadership",
        "MA, Educational Leadership (Administration and Supervision)",
        "MA, Educational Leadership, Higher Education Administration ",
        "MA, Elementary Education (Curriculum and Instruction)",
        "MA, Education (Special Education)",
        "BS, Electrical Engineering",
        "MS, Electrical Engineering",
        "BA, English",
        "BA, English (Creative Writing)",
        "BA, English (Professional and Technical Writing)",
        "BA, English (Preparation for Teaching)",
        "MA, English",
        "MFA, English, Creative Writing",
        "BA, Environmental Studies",
        "BA, Environmental Studies, Preparation for Teaching",
        "BS, Environmental Studies",
        "BS, Environmental Studies (Energy)",
        "BS, Environmental Studies (Environmental Impact Assessment)",
        "BS, Environmental Studies (Environmental Restoration and Resource Management)",
        "MS, Environmental Studies",
        "BS, General Engineering",
        "MS, Engineering",
        "MS, Engineering (Electronic Materials and Devices)",
        "BA, Geography",
        "MA, Geography",
        "BA, Earth Science",
        "BS, Geology",
        "MS, Geology",
        "BA, Global Studies",
        "BS, Health Science",
        "BS, Health Science (Health Services Administration)",
        "BS, Recreation",
        "BS, Recreation (Recreation Management)",
        "BS, Recreation (Therapeutic Recreation)",
        "MS, Recreation ",
        "MS, Recreation (International Tourism )",
        "MPH, Public Health",
        "BA, History",
        "MA, History",
        "MA, History (History Education)",
        "BS, Hospitality, Tourism and Event Management",
        "BA, Humanities (American Studies)",
        "BA, Humanities (Asian Studies)",
        "BA, Humanities (European Studies)",
        "BA, Humanities (Liberal Arts)",
        "BA, Humanities (Middle East Studies)",
        "BA, Humanities (Religious Studies)",
        "BA, Creative Arts",
        "BA, Creative Arts, Preparation for Teaching",
        "BA, Liberal Studies (Cross-Cultural Studies in Mexican and American Education)",
        "BA, Liberal Studies, Preparation for Teaching",
        "BS, Industrial and Systems Engineering",
        "MS, Engineering Management",
        "MS, Human Factors/Ergonomics",
        "MS, Industrial and Systems Engineering",
        "MLIS, Library and Information Science (also offered in Special Session)",
        "MARA, Archives and Records Administration (Special Session Program)",
        "MA, Interdisciplinary Studies",
        "MS, Interdisciplinary Studies",
        "BS, Advertising",
        "BS, Journalism",
        "BS, Public Relations",
        "MS, Mass Communication",
        "BS, Justice Studies",
        "BS, Justice Studies (Criminology)",
        "BS, Forensic Science (Biology)",
        "BS, Forensic Science (Chemistry)",
        "MS, Justice Studies",
        "BS, Kinesiology",
        "BS, Kinesiology, Preparation for Teaching",
        "BS, Athletic Training",
        "MA, Kinesiology",
        "MA, Kinesiology (Athletic Training)",
        "MA, Kinesiology (Exercise Physiology)",
        "MA, Kinesiology (Sport Management)",
        "MA, Kinesiology (Sport Studies)",
        "BA, Linguistics",
        "MA, Linguistics",
        "MA, Teaching English to Speakers of Other Languages",
        "BA, Mathematics",
        "BA, Mathematics, Preparation for Teaching",
        "BS, Applied Mathematics (Applied and Computational Mathematics)",
        "BS, Applied Mathematics (Economics and Actuarial Science)",
        "BS, Applied Mathematics (Statistics)",
        "MA, Mathematics",
        "MA, Mathematics (Mathematics Education)",
        "MS, Mathematics",
        "MS, Statistics",
        "BS, Mechanical Engineering",
        "MS, Mechanical Engineering",
        "MS, Medical Product Development Management",
        "BS, Meteorology",
        "BS, Meteorology (Climate Science)",
        "MS, Meteorology",
        "MA, Mexican American Studies",
        "BA, Humanities (Middle East Studies)",
        "MS, Marine Science",
        "BA, Dance",
        "BFA, Dance",
        "BA, Music",
        "BM, Music (Composition)",
        "BM, Music (Jazz Studies)",
        "BM, Music (Music Education)",
        "BM, Music (Performance)",
        "MM, Music",
        "BS, Nursing",
        "BS, Nursing (RN to BSN)",
        "MS, Nursing",
        "DNP, Doctor of Nursing Practioner",
        "BS, Nutritional Science",
        "BS, Nutritional Science (Dietetics)",
        "BS, Nutritional Science (Packaging)",
        "MS, Nutritional Science",
        "MS, Occupational Therapy",
        "BA, Philosophy",
        "MA, Philosophy",
        "BA, Physics",
        "BA, Physics, Preparation for Teaching",
        "BS, Physics",
        "MS, Physics",
        "MS, Physics (Computational Physics)",
        "MS, Physics (Modern Optics)",
        "BA, Political Science",
        "Masters, Public Administration",
        "BA, Psychology",
        "BS, Psychology",
        "MA, Psychology (Research and Experimental Psychology)",
        "MS, Psychology (Clinical Psychology)",
        "MS, Psychology (Industrial/Organizational Psychology)",
        "BA, Earth Science",
        "BA, Physics, Preparation for Teaching",
        "MA, Science Education",
        "BA, Social Work",
        "MSW, Master of Social Work",
        "MSW, Master of Social Work - Hybrid (Special Session Program)",
        "BA, Sociology",
        "BA, Sociology (Community Change)",
        "BA, Sociology (Race and Ethnic Studies)",
        "BA, Sociology (Social Interaction)",
        "BA, Sociology (Women, Gender and Sexuality Studies)",
        "BA, Social Science ",
        "BA, Social Science, Preparation for Teaching (Single Subject)",
        "BA, Social Science, Preparation for Teaching (Multiple Subject)",
        "MA, Sociology",
        "BS, Industrial Technology (Computer Electronics and Network Technology)",
        "BS, Industrial Technology (Manufacturing Systems)",
        "MS, Quality Assurance ",
        "BA, Radio-Television-Film",
        "BA, Theatre Arts",
        "BA, Theatre Arts, Preparation for Teaching",
        "MA, Theatre Arts ",
        "BS, Special Major",
        "MUP, Urban Planning",
        "BA, Sociology (Women, Gender and Sexuality Studies)",
        "BA, Chinese",
        "BA, French",
        "BA, French (Preparation for Teaching)",
        "BA, Japanese",
        "BA, Spanish",
        "BA, Spanish, Preparation for Teaching",
        "MA, French ",
        "MA, Spanish",
    ]
    
    let minors = [
        "Aerospace",
        "African Studies",
        "African-American Studies",
        "African Studies",
        "American Studies",
        "Anthropology",
        "Native American Studies",
        "Values, Technology and Society",
        "Architectural Studies",
        "Art Education",
        "Art History and Visual Culture",
        "Photography",
        "Studio Art",
        "Asian Studies",
        "Aviation",
        "Biological Science",
        "Science",
        "Biomedical Engineering",
        "Materials Science and Engineering",
        "Business",
        "Global Leadership and Innovation",
        "Chemistry",
        "Atypical Child Studies",
        "Child and Adolescent Development",
        "Communication Studies",
        "Communication in the Information Age",
        "Computer Science",
        "Creative Arts",
        "Graphic Design",
        "Interior Design",
        "Economics",
        "Education",
        "Atypical Child Studies",
        "Special Education",
        "Literature",
        "Comparative Literature",
        "Creative Writing",
        "Professional and Technical Writing",
        "Environmental Studies",
        "Energy Policy and Green Building",
        "Park Ranger and Administration",
        "Sustainable Water Resources",
        "Green Engineering",
        "Geography",
        "Geographic Information Science",
        "Geology",
        "Global Studies",
        "Complementary and Alternative Health Practices",
        "Health Professions",
        "Health Science",
        "Recreation",
        "Ancient and Medieval History",
        "African Studies",
        "Asian History",
        "European History",
        "Jewish Studies",
        "Latin American History",
        "Military History",
        "United States History",
        "General History",
        "Event Management",
        "Hotel and Restaurant Management",
        "American Studies",
        "Area Studies",
        "Asian Studies",
        "Creative Arts",
        "Humanities",
        "Middle East Studies",
        "Religious Studies",
        "Engineering Management",
        "Statistical Quality Engineering",
        "Jewish Studies",
        "Advertising",
        "Journalism",
        "News Media Design",
        "Public Relations",
        "Forensic Studies",
        "Human Rights",
        "Justice Studies",
        "Legal Studies",
        "Kinesiology",
        "Latin American Studies",
        "Linguistics",
        "Mathematics",
        "Mathematics Education",
        "Mathematics, For K-8 Teachers",
        "Atmospheric and Seismic Hazards",
        "Climate Change Strategies",
        "Meteorology",
        "Mexican American Studies",
        "Middle East Studies",
        "Military Science",
        "Music",
        "Dance",
        "Nutritional Science and Food Science",
        "Nutrition for Physical Performance",
        "Packaging",
        "Philosophy",
        "Physics",
        "Astronomy",
        "Applied Research Methods",
        "Political Science",
        "Public Administration and Public Policy",
        "Human Systems Integration",
        "Psychology",
        "Science Education",
        "Science Content for Teaching",
        "Social Work",
        "Asian American Studies",
        "Sociology",
        "Sociology of Education",
        "Women, Gender and Sexuality Studies",
        "Electronics",
        "Industrial Technology",
        "Manufacturing",
        "Radio-Television-Film",
        "Theatre Arts",
        "Musical Theatre",
        "Community Service Learning",
        "Urban Studies",
        "Women, Gender and Sexuality Studies",
        "Chinese",
        "French",
        "German",
        "International Business",
        "Italian",
        "Japanese",
        "Latin American Studies",
        "Portuguese",
        "Spanish",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        majorTextField.enableDropDown = true
        majorTextField.setDataSource(newDataSource: majors)
        doubleMajorField.enableDropDown = true
        doubleMajorField.setDataSource(newDataSource: majors)
    }
    
    @IBAction func addClass(_ sender: Any) {
        classFields += 1
        classesTable.beginUpdates()
        classesTable.insertRows(at: [IndexPath(row: classFields - 1, section: 0)], with: .automatic)
        classesTable.endUpdates()
    }
    
    @IBAction func addMinor(_ sender: Any) {
        minorFields += 1
        minorsTable.beginUpdates()
        minorsTable.insertRows(at: [IndexPath(row: minorFields - 1, section: 0)], with: .automatic)
        minorsTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == classesTable) {
            classFields -= 1
            classesTable.beginUpdates()
            classesTable.deleteRows(at: [indexPath], with: .top)
            classesTable.endUpdates()
        } else {
            minorFields -= 1
            minorsTable.beginUpdates()
            minorsTable.deleteRows(at: [indexPath], with: .top)
            minorsTable.endUpdates()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == classesTable) {
            return classFields
        } else {
            return minorFields
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "addClassCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AddClassCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.classNameField.enableDropDown = true
        if (tableView == classesTable) {
            cell.classNameField.setDataSource(newDataSource: majors)
        } else {
            cell.classNameField.setDataSource(newDataSource: minors)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddClassCell
        cell.isSelected = false
    }
    
    @IBAction func saveInfo(_ sender: Any) {
        if (!majors.contains(majorTextField.text!)) {
            majorTextField.shake()
        }
        if (doubleMajorField.text != "" && !majors.contains(doubleMajorField.text!)) {
            doubleMajorField.shake()
        }
        for i in 0 ..< minorFields {
            let cell = minorsTable.cellForRow(at: IndexPath(row: i, section: 0)) as! AddClassCell
            let minor = cell.classNameField.text
            if (minor != nil && minor != "") {
                if (!minors.contains(minor!)) {
                    cell.classNameField.text = ""
                    cell.classNameField.shake()
                }
            }
        }
        for i in 0 ..< classFields {
            if let cell = classesTable.cellForRow(at: IndexPath(row: i, section: 0)) as? AddClassCell {
                let course = cell.classNameField.text
                if (course != nil && course != "") {
                    if (!minors.contains(course!)) {
                        cell.classNameField.text = ""
                        cell.classNameField.shake()
                    }
                }
            }
        }
//        let extraCurricVc = self.storyboard?.instantiateViewController(withIdentifier: "initialExtraCurricularViewController")
//        self.navigationController?.pushViewController(extraCurricVc!, animated: true)
    }
    

}
