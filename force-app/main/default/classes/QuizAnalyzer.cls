public with sharing class QuizAnalyzer {
   
    private List<Wrappers.QuestionResponse> questionResponses;

    private Id quizId;
    private List<Question__c> questions;

    public QuizAnalyzer(List<Wrappers.QuestionResponse> questionResponses, Id quizId) {
        this.questionResponses = questionResponses;
        this.quizId = quizId;
    }

    public void populateCache() {
        this.questions = [
            SELECT Quiz__r.Max_Points__c, Points__c,
                (SELECT Id FROM Answers__r),
                (SELECT Answer__c, Answer__r.Answer_Content__c FROM Correct_Answers__r)
            FROM Question__c
            WHERE Quiz__c = :quizId
        ];
    }

    public Wrappers.QuizResult process() {
        Integer points = 0;
        Integer maxPoints = (Integer) this.questions[0].Quiz__r.Max_Points__c;

        for (Question__c question : this.questions) {
            points += this.processQuestion(question);
        }

        return new Wrappers.QuizResult(points, maxPoints);
    }

    private Integer processQuestion(Question__c question) {
        List<Correct_Answer__c> correctAnswers = question.Correct_Answers__r;

        for (Correct_Answer__c correctAnswer : correctAnswers) {

            if (!this.findCorrectResponse(correctAnswer.Answer__c)) {
                return 0;
            }
        }

        if (correctAnswers.size() != this.findAmountOfResponses(question.Id)) {
            return 0;
        }

        return (Integer) question.Points__c; //TODO change to question point.
    }

    private Integer findAmountOfResponses(Id questionId) {
        Integer responses = 0;
        for (Wrappers.QuestionResponse response : this.questionResponses) {
            if (response.questionId == questionId && response.response) {
                responses++;
            }
        }
        return responses;
    }

    private Boolean findCorrectResponse(Id answerId) {
        for (Wrappers.QuestionResponse response : this.questionResponses) {
            if (response.answerId == answerId) {
                return response.response;
            }
        }
        return false;
    }

}
