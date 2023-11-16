using {com.dev as dev} from '../db/schema';

service CustomerService {
    entity CustomerSrv as projection on dev.Customer;
}
