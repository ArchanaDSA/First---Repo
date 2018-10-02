trigger EventTrigger on Event (After insert,After update)
{
   List<Event> eventRec=Trigger.new;
   List<Id> Ids=new List<Id>();
   for( event rec:eventRec)
   {
   Ids.add(rec.WhatId);
   }
    system.debug('Hello from event trigger'+Ids.size());
   TasksHelper.convertActivitiesToTask(Ids);
   //TaskArjun.convertActivitiesToTask(Ids);

}