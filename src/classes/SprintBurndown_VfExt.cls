public class SprintBurndown_VfExt {
	/*
	Purpose:
		Provide baseline and actual values for a single Sprint to populate Burndown charts.
		
	Used By:
		SprintBurndown.page
	
	History:
		16-Jul-2011 Manu Erwin		Created
		16-May-2012 Manu Erwin		FIX: Merging test methods into main class
	*/

	private Sprint__c sprint;
    public SprintBurndown_VfExt(ApexPages.StandardController stdController) {
		this.sprint = [SELECT Id, Name, Start_Date__c, Total_Sprint_Days__c
					FROM Sprint__c
					WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

	    if (sprintBurndownsExist) {
	    	// Set up baseline values
	    	Decimal decTempBaselinePointsRemaining = decTotalPoints;
	    	Decimal decTempBaselineHoursRemaining = decTotalHours;
	    	Date dtWorking = sprint.Start_Date__c;
	    	for (Integer intCounter = 0; intCounter < decTotalSprintDays; intCounter++) {
				System.debug('dtWorking added to map: ' + dtWorking);
				mapBaselineDateToPointsRemaining.put(dtWorking, decTempBaselinePointsRemaining.round());
				System.debug('decTempBaselinePointsRemaining added to map: ' + decTempBaselinePointsRemaining);
				mapBaselineDateToHoursRemaining.put(dtWorking, decTempBaselineHoursRemaining.round());
				
				dtWorking = dtWorking.addDays(1);
				System.debug('dtWorking after increase: ' + dtWorking);
				decTempBaselinePointsRemaining -= decBaselinePointsPerDay;
				System.debug('decTempBaselinePointsRemaining after decrease: ' + decTempBaselinePointsRemaining);
				decTempBaselineHoursRemaining -= decBaselineHoursPerDay;
			}
			System.debug('mapBaselineDateToPointsRemaining: ' + mapBaselineDateToPointsRemaining);
			System.debug('mapBaselineDateToHoursRemaining: ' + mapBaselineDateToHoursRemaining);
	
			for (Sprint_Burndown__c sprintBurndown : listSprintBurndowns) {
				mapDateToSprintBurndown.put(sprintBurndown.Date__c, sprintBurndown);
			}
	    }
    }
	private List<Sprint_Burndown__c> listSprintBurndowns {
		get {
			// TODO: Dynamically obtain and use the page record id in this query
			if (listSprintBurndowns == null) {
				listSprintBurndowns = [SELECT Id, Date__c, Sprint__c, Sprint__r.Total_Sprint_Days__c,
						Total_Points_Remaining__c, Total_Hours_Remaining__c
						FROM Sprint_Burndown__c
						WHERE Sprint__c = :sprint.Id
						ORDER BY Date__c];
			}
			return listSprintBurndowns;
		}
		set;
	}
	public Boolean sprintBurndownsExist {
		get {
			if (sprintBurndownsExist == null) {
				if (listSprintBurndowns.size() == 0) {
					sprintBurndownsExist = false;
				} else {
					sprintBurndownsExist = true;
				}
			}
			return sprintBurndownsExist;
		}
		set;
	}
	private Map<Date, Sprint_Burndown__c> mapDateToSprintBurndown {
		get {
			if (mapDateToSprintBurndown == null) {
				mapDateToSprintBurndown = new Map<Date, Sprint_Burndown__c>();
			}
			return mapDateToSprintBurndown;
		}
		set;
	}
	private Sprint_Burndown__c firstSprintBurndown {
		get {
			if (firstSprintBurndown == null) {
				// TODO: handle scenario of zero records
				firstSprintBurndown = listSprintBurndowns[0];
			}
			return firstSprintBurndown;
		}
		set;
	}
	private Decimal decTotalSprintDays {
		get {
			if (decTotalSprintDays == null) {
				decTotalSprintDays = sprint.Total_Sprint_Days__c + 1;
			}
			return decTotalSprintDays;
		}
		set;
	}
	private Decimal decTotalPoints {
		get {
			if (decTotalPoints == null) {
				decTotalPoints = firstSprintBurndown.Total_Points_Remaining__c;
			}
			return decTotalPoints;
		}
		set;
	}
	private Decimal decTotalHours {
		get {
			if (decTotalHours == null) {
				decTotalHours = firstSprintBurndown.Total_Hours_Remaining__c;
			}
			return decTotalHours;
		}
		set;
	}
	private Decimal decBaselinePointsPerDay {
		get {
			if (decBaselinePointsPerDay == null) {
				decBaselinePointsPerDay = decTotalPoints/(decTotalSprintDays - 1);
			}
			return decBaselinePointsPerDay;
		}
		set;
	}
	private Decimal decBaselineHoursPerDay {
		get {
			if (decBaselineHoursPerDay == null) {
				decBaselineHoursPerDay = decTotalHours/(decTotalSprintDays - 1);
			}
			return decBaselineHoursPerDay;
		}
		set;
	}
	private Map<Date, Decimal> mapBaselineDateToPointsRemaining {
		get {
			if (mapBaselineDateToPointsRemaining == null) {
				mapBaselineDateToPointsRemaining = new Map<Date, Decimal>();
			}
			return mapBaselineDateToPointsRemaining;
		}
		set;
	}
	private Map<Date, Decimal> mapBaselineDateToHoursRemaining {
		get {
			if (mapBaselineDateToHoursRemaining == null) {
				mapBaselineDateToHoursRemaining = new Map<Date, Decimal>();
			}
			return mapBaselineDateToHoursRemaining;
		}
		set;
	}
    public String getPointsRemainingOverTime(){
        GoogleViz gv = new GoogleViz();
        gv.cols = new list<GoogleViz.col> { 
            new GoogleViz.Col('col1','Date','string'),
            new GoogleViz.Col('col2','Baseline Points Remaining','number'),
            new GoogleViz.Col('col2','Actual Points Remaining','number')
        };
    	Date dtWorking = sprint.Start_Date__c;
    	for (Integer intCounter = 0; intCounter < decTotalSprintDays; intCounter++) {
	        System.debug('intCounter: ' + intCounter);
	        GoogleViz.row gvRow = new GoogleViz.row();
	        System.debug('dtWorking: ' + dtWorking);
	        gvRow.cells.add (new GoogleViz.cell (dtWorking));
	        System.debug('mapBaselineDateToPointsRemaining: ' + mapBaselineDateToPointsRemaining.get(dtWorking));
	        gvRow.cells.add (new GoogleViz.cell (mapBaselineDateToPointsRemaining.get(dtWorking)));
	        if (mapDateToSprintBurndown.get(dtWorking) != null) {
		        System.debug('mapDateToSprintBurndown: ' + mapDateToSprintBurndown.get(dtWorking).Total_Points_Remaining__c);
		        gvRow.cells.add (new GoogleViz.cell (mapDateToSprintBurndown.get(dtWorking).Total_Points_Remaining__c));
	        }
	        gv.addRow(gvRow);
	        dtWorking = dtWorking.addDays(1);
		}
        return gv.toJsonString();
    }
    public String getHoursRemainingOverTime(){
        GoogleViz gv = new GoogleViz();
        gv.cols = new list<GoogleViz.col> { 
            new GoogleViz.Col('col1','Date','string'),
            new GoogleViz.Col('col2','Baseline Hours Remaining','number'),
            new GoogleViz.Col('col2','Actual Hours Remaining','number')
        };
    	Date dtWorking = sprint.Start_Date__c;
    	for (Integer intCounter = 0; intCounter < decTotalSprintDays; intCounter++) {
	        GoogleViz.row gvRow = new GoogleViz.row();
	        gvRow.cells.add (new GoogleViz.cell (dtWorking));
	        gvRow.cells.add (new GoogleViz.cell (mapBaselineDateToHoursRemaining.get(dtWorking)));
	        if (mapDateToSprintBurndown.get(dtWorking) != null) {
		        gvRow.cells.add (new GoogleViz.cell (mapDateToSprintBurndown.get(dtWorking).Total_Hours_Remaining__c));
	        }
	        gv.addRow(gvRow);
	        
	        dtWorking = dtWorking.addDays(1);
		}
        return gv.toJsonString();
    }

	/* TEST METHODS */
    @isTest static void noSprintBurndownsExist_Test() {
        Sprint__c sprint = new Sprint__c(Name = 'noSprintBurndownsExist', Status__c = 'In Progress',
        						Start_Date__c = System.today(), End_Date__c = System.today().addDays(30));
        insert sprint;

		Test.startTest();
		Test.setCurrentPage(Page.SprintBurndown);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		System.debug('## DEBUG: sprint prior to VF: ' + sprint);
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		ApexPages.currentPage().getParameters().put('id', sprint.Id);
		SprintBurndown_VfExt sprintBurnCon = new SprintBurndown_VfExt(controller);

		Boolean bolBurndownsExist = sprintBurnCon.sprintBurndownsExist;
		System.assert(!bolBurndownsExist, 'There should be no Sprint Burndowns: ' + bolBurndownsExist);
		Test.stopTest();
    }
    @isTest static void sprintBurndownsExist_Test() {
        Sprint__c sprint = new Sprint__c(Name = 'sprintBurndownsExist_Test', Status__c = 'In Progress',
        					Start_Date__c = System.today(), End_Date__c = System.today().addDays(30));
        insert sprint;

		List<Sprint_Burndown__c> listSprintBurndowns = new List<Sprint_Burndown__c>();
		Integer intCountDays = 0;
		for (Integer intCount = 25; intCount > 0; intCount--) {
			Sprint_Burndown__c sprintBurn = new Sprint_Burndown__c(Sprint__c = sprint.Id, Date__c = System.today().addDays(intCountDays),
									Total_Points_Remaining__c = intCount, Total_Hours_Remaining__c = intCount);
			intCountDays++;
			listSprintBurndowns.add(sprintBurn);
		}
		insert listSprintBurndowns;

		Test.startTest();
		Test.setCurrentPage(Page.SprintBurndown);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		ApexPages.currentPage().getParameters().put('id', sprint.Id);
		SprintBurndown_VfExt sprintBurnCon = new SprintBurndown_VfExt(controller);

		Boolean bolBurndownsExist = sprintBurnCon.sprintBurndownsExist;
		System.assert(bolBurndownsExist, 'There should be Sprint Burndowns: ' + bolBurndownsExist);

		String strHoursRemaining = sprintBurnCon.getHoursRemainingOverTime();
		String strPointsRemaining = sprintBurnCon.getPointsRemainingOverTime();
		Test.stopTest();
    }
}