# STAT 515 - Exploring the Relationship Between Arrangments and Employee Well-Being  
# Remote Work Health Impact Survey 2025

## Objective
# Analysing how remote, hybrid, and onsite working arrangments differ in terms of employee burnout, work-life balance, and social isolation?


# 1.) Import dataset
remote_work <- read.csv(
  "post_pandemic_remote_work_health_impact_2025.csv"
)

# 2.) Explore dataset
head(remote_work)
str(remote_work)
summary(remote_work)

# 3.) Check missing values
colSums(is.na(remote_work))

# 4.) Check dataset dimensions
dim(remote_work)

# 5.) View column names
names(remote_work)


##INSPECTING DATASET


# 6.) Check work arrangement categories
table(remote_work$Work_Arrangement)

# 7.) Examine work-life balance scores
summary(remote_work$Work_Life_Balance_Score)

# 8.) Examine social isolation scores
summary(remote_work$Social_Isolation_Score)

# 9.) Examine weekly working hours
summary(remote_work$Hours_Per_Week)



##TRANSFORMATIONS

# 10.) Transform work arrangement into a factor
remote_work$Work_Arrangement <- factor(
  remote_work$Work_Arrangement,
  levels = c("Onsite", "Hybrid", "Remote")
)

# 11.) Transform burnout into an ordered factor
remote_work$Burnout_Level <- factor(
  remote_work$Burnout_Level,
  levels = c("Low", "Medium", "High"),
  ordered = TRUE
)

# 12.) Verify transformations
str(remote_work)
table(remote_work$Burnout_Level, useNA = "ifany")



##CREATE CALCULATED COLUMN

# 13.) Create calculated column based on weekly hours
remote_work$Workload_Category <- ifelse(
  remote_work$Hours_Per_Week > 40,
  "Over 40 Hours",
  "40 Hours or Less"
)

# 14.) Convert calculated column to a factor
remote_work$Workload_Category <- factor(
  remote_work$Workload_Category,
  levels = c("40 Hours or Less", "Over 40 Hours")
)

# 15.) Verify the new column
table(remote_work$Workload_Category)

# 16.) Check updated dimensions
dim(remote_work)


##VISUALIZATIONS

library(ggplot2)

# Calculate average work-life balance by arrangement
balance_summary <- aggregate(
  Work_Life_Balance_Score ~ Work_Arrangement,
  data = remote_work,
  FUN = mean
)

# Display results
balance_summary

# Create visualization
ggplot(
  balance_summary,
  aes(
    x = Work_Arrangement,
    y = Work_Life_Balance_Score,
    fill = Work_Arrangement
  )
) +
  geom_col(width = 0.6) +
  geom_text(
    aes(label = round(Work_Life_Balance_Score, 2)),
    vjust = -0.5
  ) +
  scale_y_continuous(limits = c(0, 5)) +
  labs(
    title = "Average Work-Life Balance by Work Arrangement",
    subtitle = "Remote Work Health Impact Survey 2025",
    x = "Work Arrangement",
    y = "Average Work-Life Balance Score",
    fill = "Work Arrangement"
  ) +
  theme_minimal()

#########################################################################
# The first visualization compares the avg work-life balance scores across employee with hybrid, onsite, and remote work arrangement.
# Onsite employees have the highest avg score of 3.03, followed by remote at 2.99, and hybrid at 2.95.
# However, the differences were relatively small, it suggests that work arrangement alone may not explain much of the variation in work-life balance
########################################################################

################################################################################
# Visualization 2: Social Isolation by Work Arrangement
################################################################################

library(ggplot2)

ggplot(
  remote_work,
  aes(
    x = Work_Arrangement,
    y = Social_Isolation_Score,
    fill = Work_Arrangement
  )
) +
  geom_boxplot(width = 0.6) +
  labs(
    title = "Social Isolation by Work Arrangement",
    subtitle = "Remote Work Health Impact Survey 2025",
    x = "Work Arrangement",
    y = "Social Isolation Score (1-5)",
    fill = "Work Arrangement"
  ) +
  theme_minimal()

#########################################################################
# The second visualization looks at social isolation scores across different work arrangements.
# Remote employees seem to report the highest levels of socisl isolation, followed by hybrid, while onsite employees generally report the lowest levels.
# Unlike work-life balance, where average scores were relatively similar, social isolation shows more noticeable differences between the groups. 
# This suggests that work arrangement may be more closely associated with feelings of isolation than with overall work-life balance.
########################################################################


################################################################################
# Visualization 3: Burnout Level by Weekly Workload
################################################################################

library(ggplot2)

ggplot(
  remote_work,
  aes(
    x = Workload_Category,
    fill = Burnout_Level
  )
) +
  geom_bar(
    position = "fill",
    width = 0.6
  ) +
  scale_y_continuous(
    labels = scales::percent
  ) +
  labs(
    title = "Burnout Levels by Weekly Workload",
    subtitle = "Remote Work Health Impact Survey 2025",
    x = "Weekly Workload",
    y = "Percentage of Employees",
    fill = "Burnout Level"
  ) +
  theme_minimal()

#########################################################################
# The third visualization looks at burnout levels among employees working more than 40 hours.
# Both groups show relatively similar distributions of low, medium, and high burnout. 
# Although longer working hours might be expected to correspond with greater burnout, the results don't reveal a noticeable difference between the workload categories.
# This suggests that weekly working hours alone may not explain differences in reported burnout.
########################################################################

# Calculate burnout percentages by workload
burnout_table <- prop.table(
  table(
    remote_work$Workload_Category,
    remote_work$Burnout_Level
  ),
  margin = 1
) * 100

round(burnout_table, 1)

################################## Updated Interpretation 
# The third visualization compares burnout levels between employees working 40 hours or less and those working more than 40 hours per week.
# The distributions were surprisingly similar across both groups. High burnout was reported by 34.5% of employees working 40 hours or less, compared with 32.8% of those working longer hours. 
# Medium burnout was almost identical at approximately 43% in both groups. 
# These findings suggest that weekly working hours alone may not be a strong indicator of burnout in this dataset.






