lonEEP = [220 280]; % 140W-80W
latEEP = [-5 5];
lonWEP = [150 200]; % 150E-160W
latWEP = [-5 5];

hold on;
boxlinewidth=2;
boxlinestyle=':';

m_line(lonEEP,[latEEP(1) latEEP(1)],'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line(lonEEP,[latEEP(2) latEEP(2)],'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line([lonEEP(1) lonEEP(1)],latEEP,'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line([lonEEP(2) lonEEP(2)],latEEP,'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);

m_line(lonWEP,[latWEP(1) latWEP(1)],'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line(lonWEP,[latWEP(2) latWEP(2)],'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line([lonWEP(1) lonWEP(1)],latWEP,'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
m_line([lonWEP(2) lonWEP(2)],latWEP,'color','k','linewidth',boxlinewidth,'linestyle',boxlinestyle);
