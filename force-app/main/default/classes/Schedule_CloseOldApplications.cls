public class Schedule_CloseOldApplications implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CloseOldApplications(), 200);
    }
}
